import SwiftUI

struct PhaseFinalView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .notifications: notificationsView
            case .finalWelcome: finalWelcomeView
            case .dashboard: dashboardView
            default: EmptyView()
            }
        }
    }
    
    // Screen 23: Notifications
    var notificationsView: some View {
        StepLayout(
            title: "Reach your goals with notifications",
            subtitle: "Stay on track with daily insights tailored to your journey.",
            showProgressBar: false,
            centerContent: true,
            hideBackButton: true,
            centerTitle: true
        ) {
            VStack(spacing: 32) {
                Spacer()
                NotificationPrompt()
                Spacer()
                VStack(spacing: 12) {
                    PrimaryButton(title: "Continue") {
                        model.goToStep(.finalWelcome)
                    }
                    PrimaryButton(title: "Not Now", variant: .ghost) {
                        model.goToStep(.finalWelcome)
                    }
                }
                .padding(.bottom, 20)
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
                Text("Dashboard Placeholder")
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
}

private struct NotificationPrompt: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("“Aura” Would Like to Send You Notifications")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.")
                    .font(.system(size: 14))
                    .foregroundColor(.zinc500)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
            Divider().background(Color.zinc900)
            HStack(spacing: 0) {
                Text("Don't Allow")
                    .font(.system(size: 16))
                    .foregroundColor(.zinc500)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .overlay(Rectangle().stroke(Color.zinc900, lineWidth: 0.5))
                Text("Allow")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
            }
        }
        .background(Color.zinc900)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.zinc800, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 10)
        .padding(.horizontal)
    }
}
