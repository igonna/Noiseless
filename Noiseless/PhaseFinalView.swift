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
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            ZStack {
                LinearGradient(colors: [.zinc950, Color.zinc900.opacity(0.4), .zinc950], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 32) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 220, height: 220)
                            .blur(radius: 60)
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .overlay(Circle().fill(Color.black).frame(width: 60, height: 60))
                    }
                    
                    VStack(spacing: 16) {
                        Text("Welcome to Noiseless.")
                            .font(.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Text("Your personal model is ready — your first insight is waiting.")
                            .font(.system(size: 18))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    Spacer()
                    PrimaryButton(title: "See My Insight") {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        model.goToStep(.dashboard)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    private var dashboardView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Welcome to Noiseless")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.zinc400)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Focus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.zinc500)
                        .textCase(.uppercase)
                    Text("Review your career transition strategy.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.zinc900)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                
                Text("This is where the actual application begins. The onboarding flow is complete.")
                    .font(.system(size: 15))
                    .foregroundColor(.zinc400)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                PrimaryButton(title: "Restart Demo", variant: .secondary, fullWidth: false) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    model.goToStep(.welcome)
                }
            }
            .padding()
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
                .padding(.bottom, 16)
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
