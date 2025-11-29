import SwiftUI
import UserNotifications

struct PhaseFinalView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .notifications: notificationsView
            case .integrations: integrationsView
            case .finalWelcome: finalWelcomeView
            case .firstSuggestion: firstSuggestionView
            case .habitLoop: habitLoopView
            case .dashboard: dashboardView
            default: EmptyView()
            }
        }
    }
    
    // Screen 23: Notifications
    var notificationsView: some View {
        StepLayout(
            showProgressBar: false,
            centerContent: true,
            hideBackButton: true
        ) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 156)

                VStack(spacing: 24) {
                    Text("Reach your goals with notifications")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)

                    NotificationPrompt(onAllow: {
                        requestNotificationPermission()
                    })
                }

                Spacer()
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                // Navigate to next screen after permission request
                model.goToStep(.finalWelcome)
            }
        }
    }
    
    // Screen 25: Final Welcome
    var finalWelcomeView: some View {
        StepLayout(
            showProgressBar: false,
            centerContent: true,
            hideBackButton: true,
            horizontalPadding: 0,
            topPadding: 0
        ) {
            FinalWelcomeContent(onContinue: {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                model.goToStep(.dashboard)
            })
        }
    }
    
    private var dashboardView: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()

            FinalGlowBackdrop()

            VStack(spacing: 32) {
                Spacer()

                Text("Welcome to Noiseless")
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Spacer()

                PrimaryButton(title: "Restart Demo", variant: .secondary, fullWidth: false) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    model.goToStep(.welcome)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
    }

    // Screen 24: Integrations (Skipped in current flow)
    var integrationsView: some View {
        StepLayout(
            title: "Connect Your Tools",
            subtitle: "Integrate with the apps you already use.",
            showProgressBar: false,
            centerContent: true,
            hideBackButton: true,
            centerTitle: true
        ) {
            VStack(spacing: 32) {
                Spacer()
                Text("Coming soon...")
                    .font(.system(size: 18))
                    .foregroundColor(.zinc500)
                Spacer()
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }

    // Screen 26: First Suggestion (Not implemented in React - placeholder)
    var firstSuggestionView: some View {
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            VStack(spacing: 32) {
                Spacer()
                Text("Your first suggestion is ready")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }

    // Screen 27: Habit Loop (Not implemented in React - placeholder)
    var habitLoopView: some View {
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            VStack(spacing: 32) {
                Spacer()
                Text("Build lasting habits")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
}

private struct NotificationPrompt: View {
    let onAllow: () -> Void
    @State private var pointingOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("Noiseless would like to send you Notifications")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
                Divider().background(Color.zinc900)
                HStack(spacing: 0) {
                    Text("Don't Allow")
                        .font(.system(size: 18))
                        .foregroundColor(.zinc500)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .overlay(Rectangle().stroke(Color.zinc900, lineWidth: 0.5))
                    Button(action: onAllow) {
                        Text("Allow")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.zinc900)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.zinc800, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 10)

            // Pointing hand animation
            Text("👉")
                .font(.system(size: 40))
                .rotationEffect(.degrees(-90))
                .offset(x: -50, y: 65 + pointingOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        pointingOffset = -8
                    }
                }
        }
        .padding(.horizontal)
    }
}

private struct FinalWelcomeContent: View {
    let onContinue: () -> Void
    @State private var showWelcomeLine = false
    @State private var showNoiselessLine = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            Color.zinc950
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.system(size: 22, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.85))
                        .opacity(showWelcomeLine ? 1 : 0)

                    Text("Noiseless.")
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .opacity(showNoiselessLine ? 1 : 0)
                }
                .padding(.horizontal, 32)

                Spacer()

                PrimaryButton(title: "See My Insight", enableHaptics: false) {
                    HapticManager.trigger(.impact(.soft))
                    onContinue()
                }
                    .padding(.bottom, 40)
                    .opacity(showButton ? 1 : 0)
                    .animation(nil, value: showButton)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            showWelcomeLine = false
            showNoiselessLine = false
            showButton = false

            withAnimation(.easeInOut(duration: 1.5)) {
                showWelcomeLine = true
            }
            withAnimation(.easeInOut(duration: 1.5).delay(2.0)) {
                showNoiselessLine = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                HapticManager.trigger(.impact(.soft))
                showButton = true
            }
        }
    }
}

private struct FinalGlowBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Color.zinc950
                    .ignoresSafeArea()

                GlowOrb(
                    size: width * 0.9,
                    color: Color(hex: "#8FD3FF"),
                    blur: 120,
                    xOffset: -width * 0.2,
                    yOffset: -height * 0.25,
                    animationDuration: 3.8
                )

                GlowOrb(
                    size: width * 0.75,
                    color: Color(hex: "#C5A3FF"),
                    blur: 140,
                    xOffset: width * 0.35,
                    yOffset: height * 0.1,
                    animationDuration: 4.6
                )

                GlowOrb(
                    size: width * 0.6,
                    color: Color(hex: "#6AD2C9"),
                    blur: 110,
                    xOffset: -width * 0.05,
                    yOffset: height * 0.35,
                    animationDuration: 4.1
                )

                GlowOrb(
                    size: width * 0.4,
                    color: Color.white.opacity(0.4),
                    blur: 90,
                    xOffset: width * 0.25,
                    yOffset: height * 0.45,
                    animationDuration: 3.2,
                    animationRange: 0.05
                )
            }
            .frame(width: width, height: height)
        }
        .allowsHitTesting(false)
    }
}

private struct GlowOrb: View {
    let size: CGFloat
    let color: Color
    let blur: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    var animationDuration: Double = 4.0
    var animationRange: CGFloat = 0.12

    @State private var isGlowing = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(isGlowing ? 0.45 : 0.2),
                        color.opacity(0.01)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blur)
            .scaleEffect(isGlowing ? 1 + animationRange : 1 - animationRange)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}
