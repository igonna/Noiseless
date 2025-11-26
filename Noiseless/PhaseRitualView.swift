import SwiftUI

struct PhaseRitualView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var progress: CGFloat = 0.0
    @State private var statusText: String = "Analyzing your profile..."
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .buildingModel, .calibrating, .pathReady:
                ritualView
            default: EmptyView()
            }
        }
    }
    
    var ritualView: some View {
        StepLayout(showProgressBar: false, centerContent: true) {
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.zinc800, lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    // Progress Ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    // Inner Pulse
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(progress < 1.0 ? 1.0 : 1.2)
                        .animation(progress < 1.0 ? .easeInOut(duration: 1).repeatForever() : .default, value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(statusText)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.zinc400)
                    .transition(.opacity)
                    .id(statusText)
                
                Spacer()
                
                if progress >= 1.0 {
                    PrimaryButton(title: "See My Plan") {
                        model.nextStep() // Moves to InsightsPreview
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            handleStepChange()
        }
        .onChange(of: model.currentStep) { _ in
            handleStepChange()
        }
    }
    
    func handleStepChange() {
        if model.currentStep == .buildingModel {
            statusText = "Analyzing your profile..."
            progress = 0.0
            withAnimation(.linear(duration: 2.0)) {
                progress = 0.33
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                model.goToStep(.calibrating)
            }
        } else if model.currentStep == .calibrating {
            statusText = "Calibrating your path..."
            // Start timer for the rest of the progress
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if progress < 1.0 {
                    progress += 0.01
                    
                    if progress > 0.66 && progress < 0.95 {
                        statusText = "Finalizing insights..."
                    } else if progress >= 0.99 {
                        statusText = "Your plan is ready."
                        timer.invalidate()
                        progress = 1.0
                        // Delay slightly before showing button or moving next
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            model.goToStep(.pathReady)
                        }
                    }
                } else {
                    timer.invalidate()
                }
            }
        } else if model.currentStep == .pathReady {
            progress = 1.0
            statusText = "Your plan is ready."
        }
    }
}
