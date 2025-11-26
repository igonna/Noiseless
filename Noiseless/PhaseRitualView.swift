import SwiftUI

struct PhaseRitualView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .buildingModel, .calibrating:
                ProcessingStepsView()
            case .pathReady:
                PathReadyView()
            default:
                EmptyView()
            }
        }
    }
}

private struct ProcessingStepsView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var completedCount: Int = 0
    @State private var timer: Timer?
    @State private var animateGlow = false
    
    private let steps = [
        "Analyzing your strengths",
        "Interpreting goals & values",
        "Mapping your constraints",
        "Connecting skills & curiosity",
        "Reading local opportunities",
        "Designing your path forward"
    ]
    
    private var progress: CGFloat {
        guard !steps.isEmpty else { return 0 }
        return min(CGFloat(completedCount) / CGFloat(steps.count), 1)
    }
    
    var body: some View {
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            ZStack {
                movingGlow
                VStack(spacing: 24) {
                    header
                    checklist
                    footer
                }
            }
        }
        .onAppear(perform: startProcessing)
        .onDisappear { timer?.invalidate() }
        .onChange(of: model.currentStep) { step in
            guard step == .buildingModel || step == .calibrating else { return }
            startProcessing()
        }
    }
    
    private var header: some View {
        VStack(spacing: 20) {
            Text("We're setting everything up for you")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Processing")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                        .tracking(2)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                progressBar
            }
        }
        .padding(.top, 24)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.zinc800)
                    .frame(height: 8)
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(progress * width, 0), height: 8)
                    .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 8)
    }
    
    private var checklist: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                    let state = stepState(for: index)
                    HStack(spacing: 16) {
                        icon(for: state)
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(state == .pending ? .zinc600 : .white)
                            .animation(.easeInOut(duration: 0.25), value: state)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            Divider().background(Color.zinc900)
            Text("Building your personal model...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.zinc600)
                .tracking(1)
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: completedCount)
        }
        .padding(.bottom, 12)
    }
    
    private func stepState(for index: Int) -> StepState {
        if index < completedCount {
            return .completed
        } else if index == completedCount {
            return .active
        } else {
            return .pending
        }
    }
    
    private func icon(for state: StepState) -> some View {
        Group {
            switch state {
            case .completed:
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.white.opacity(0.15)))
            case .active:
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.white.opacity(0.6), radius: 8, x: 0, y: 0)
            case .pending:
                Circle()
                    .fill(Color.zinc700)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var movingGlow: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 420, height: 420)
                .offset(x: animateGlow ? -80 : -140, y: animateGlow ? -180 : -220)
                .blur(radius: 80)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGlow)
            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 380, height: 380)
                .offset(x: animateGlow ? 120 : 160, y: animateGlow ? 140 : 180)
                .blur(radius: 90)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animateGlow)
        }
    }
    
    private func startProcessing() {
        timer?.invalidate()
        completedCount = 0
        if !animateGlow {
            animateGlow = true
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if completedCount < steps.count {
                completedCount += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    model.goToStep(.pathReady)
                }
            }
        }
    }
    
    private enum StepState {
        case completed, active, pending
    }
}

private struct PathReadyView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                ZStack {
                    Circle()
                        .fill(Color.zinc800.opacity(0.4))
                        .frame(width: 240, height: 240)
                        .blur(radius: 60)
                    Circle()
                        .stroke(Color.zinc700, lineWidth: 1)
                        .frame(width: 180, height: 180)
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 16) {
                    Text("Congratulations — your custom plan is ready!")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Text("Built from your strengths, goals, and context — optimized for results.")
                        .font(.system(size: 18))
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                Spacer()
                PrimaryButton(title: "Let's get started!") {
                    model.nextStep()
                }
                .padding(.bottom, 24)
            }
        }
    }
}
