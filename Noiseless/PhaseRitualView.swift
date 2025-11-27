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
    @State private var smoothProgress: Double = 0.0
    @State private var blueGlowOffset: CGSize = CGSize(width: -140, height: -220)
    @State private var violetGlowOffset: CGSize = CGSize(width: 160, height: 180)
    @State private var blueGlowScale: CGFloat = 1.0
    @State private var violetGlowScale: CGFloat = 1.0
    @State private var blueGlowOpacity: Double = 0.3
    @State private var violetGlowOpacity: Double = 0.2
    @State private var footerOpacity: Double = 0.6

    private let steps = [
        "Analyzing your strengths",
        "Interpreting your goals & values",
        "Mapping your constraints",
        "Connecting skills & curiosity",
        "Reading local opportunities",
        "Designing your path forward"
    ]

    private var progress: Int {
        guard !steps.isEmpty else { return 0 }
        if completedCount >= steps.count {
            return 100
        }
        // Show progress up to 99% until all complete
        return min(Int(round(Double(completedCount) / Double(steps.count) * 99)), 99)
    }

    var body: some View {
        ZStack {
            Color.zinc950
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                headerSection
                checklistSection
                footerSection
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startProcessing()
            startBackgroundAnimations()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: model.currentStep) { step in
            guard step == .buildingModel || step == .calibrating else { return }
            startProcessing()
        }
    }


    // MARK: - UI Components

    private var backgroundGlows: some View {
        ZStack {
            // Blue glow - top left
            Circle()
                .fill(Color.blue.opacity(blueGlowOpacity))
                .frame(width: 500, height: 500)
                .blur(radius: 100)
                .offset(blueGlowOffset)
                .scaleEffect(blueGlowScale)

            // Violet glow - bottom right
            Circle()
                .fill(Color.purple.opacity(violetGlowOpacity))
                .frame(width: 500, height: 500)
                .blur(radius: 100)
                .offset(violetGlowOffset)
                .scaleEffect(violetGlowScale)
        }
        .allowsHitTesting(false)
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            // Title - centered, max-w-xs (320px)
            Text("We're setting everything up for you")
                .font(.system(size: 30, weight: .bold))
                .tracking(-0.5)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(maxWidth: 320)
                .padding(.top, 120)
                .padding(.bottom, 32)
                .opacity(completedCount >= 0 ? 1 : 0)
                .offset(y: completedCount >= 0 ? 0 : 10)
                .animation(.easeOut(duration: 0.6), value: completedCount)

            // Progress section - max-w-xs (320px) centered with px-2 (8px horizontal padding)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("PROCESSING")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                        .tracking(1.5)
                    Spacer()
                    Text("\(progress)%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.1), value: progress)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.zinc800)
                            .frame(height: 6)

                        Capsule()
                            .fill(Color.white)
                            .frame(width: max(smoothProgress / 100.0 * geo.size.width, 0), height: 6)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: 320)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity) // Center the container
        .padding(.bottom, 24)
    }

    private var checklistSection: some View {
        // Checklist - max-w-xs (320px) centered with pl-2 (8px left padding)
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                    ChecklistRow(
                        title: title,
                        state: stepState(for: index),
                        index: index
                    )
                }
            }
            .frame(maxWidth: 320, alignment: .leading)
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, alignment: .center) // Center the 320px container
        }
    }

    private var footerSection: some View {
        VStack(spacing: 0) {
            Text("Building your personal model...")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.zinc600)
                .tracking(0.5)
                .padding(.top, 12)
                .opacity(footerOpacity)
        }
    }


    // MARK: - Helper Functions

    private func stepState(for index: Int) -> StepState {
        if index < completedCount {
            return .completed
        } else if index == completedCount {
            return .active
        } else {
            return .pending
        }
    }

    private func startBackgroundAnimations() {
        // Blue glow animation
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            blueGlowOffset = CGSize(width: -80, height: -180)
            blueGlowScale = 1.1
            blueGlowOpacity = 0.5
        }

        // Violet glow animation (with delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                violetGlowOffset = CGSize(width: 120, height: 140)
                violetGlowScale = 1.2
                violetGlowOpacity = 0.4
            }
        }

        // Footer text blinking animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            footerOpacity = 0.2
        }
    }
    
    private func startProcessing() {
        timer?.invalidate()
        completedCount = 0
        smoothProgress = 0.0

        // Calculate total time for checklist (6 items × 0.75s = 4.5s)
        let checklistDuration = Double(steps.count) * 0.75

        // Smooth progress animation to 95% - sync with checklist completion
        withAnimation(.linear(duration: checklistDuration)) {
            smoothProgress = 95.0
        }

        // Checklist items appear at regular intervals
        var currentIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { timer in
            if currentIndex < steps.count {
                completedCount += 1
                currentIndex += 1

                // When all items are checked, pause then complete
                if currentIndex == steps.count {
                    timer.invalidate()

                    // Pause at 95% for 0.8 seconds (slowdown)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        // Strong haptic at completion
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()

                        // Update completedCount to show 100% FIRST
                        completedCount = steps.count + 1

                        // Then animate progress bar to catch up to 100%
                        withAnimation(.easeOut(duration: 0.3)) {
                            smoothProgress = 100.0
                        }

                        // Navigate to next screen after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            model.goToStep(.pathReady)
                        }
                    }
                }
            }
        }
    }

    enum StepState {
        case completed, active, pending
    }
}

// MARK: - Checklist Row Component

private struct ChecklistRow: View {
    let title: String
    let state: ProcessingStepsView.StepState
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Icon
            ZStack {
                switch state {
                case .completed:
                    CheckmarkIcon()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .frame(width: 20, height: 20)
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: appeared)

                case .active:
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)

                case .pending:
                    Circle()
                        .fill(Color.zinc800)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 20, height: 20, alignment: .center)

            // Text
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(state == .pending ? .zinc600 : .white)
                .animation(.easeInOut(duration: 0.5), value: state)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(Double(index) * 0.1)) {
                appeared = true
            }
        }
        .onChange(of: state) { newState in
            if newState == .completed {
                // Trigger haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                appeared = true
            }
        }
    }
}

// Custom checkmark shape to match Lucide's Check icon
// Based on: <path d="M20 6 9 17l-5-5"/>
private struct CheckmarkIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Scale from 24x24 viewBox to our rect
        let scaleX = width / 24.0
        let scaleY = height / 24.0

        // Path: M20 6 L9 17 l-5-5
        // M20 6
        path.move(to: CGPoint(x: 20 * scaleX, y: 6 * scaleY))
        // L9 17
        path.addLine(to: CGPoint(x: 9 * scaleX, y: 17 * scaleY))
        // l-5-5 (relative: move -5 in x, -5 in y from current point)
        path.addLine(to: CGPoint(x: 4 * scaleX, y: 12 * scaleY))

        return path
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
                    Text("Congratulations your custom plan is ready!")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Text("Built from your strengths, goals, and real-world context — optimized for results.")
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
