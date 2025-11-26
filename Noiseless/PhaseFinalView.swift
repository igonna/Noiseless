import SwiftUI

struct PhaseFinalView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .notifications: notificationsView
            case .integrations: integrationsView
            case .finalWelcome: finalWelcomeView
            default: EmptyView()
            }
        }
    }
    
    // Screen 23: Notifications
    var notificationsView: some View {
        StepLayout(centerContent: true) {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Text("Stay on track.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Enable notifications to get your daily insights at the perfect time.")
                        .font(.system(size: 18))
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    PrimaryButton(title: "Enable Notifications") {
                        // Request permission logic here
                        model.nextStep()
                    }
                    
                    Button(action: {
                        model.nextStep()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.zinc500)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Screen 24: Integrations (Optional)
    var integrationsView: some View {
        StepLayout(title: "Connect your apps.", subtitle: "Get better insights by connecting your data.") {
            VStack(spacing: 16) {
                IntegrationRow(icon: "figure.walk", name: "HealthKit", isConnected: false)
                IntegrationRow(icon: "calendar", name: "Calendar", isConnected: true)
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Screen 25: Final Welcome
    var finalWelcomeView: some View {
        StepLayout(centerContent: true) {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 0)
                
                VStack(spacing: 16) {
                    Text("Welcome to Aura.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personalized dashboard is ready.")
                        .font(.system(size: 18))
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                PrimaryButton(title: "Go to Dashboard") {
                    // Complete onboarding
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    model.goToStep(.dashboard)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct IntegrationRow: View {
    let icon: String
    let name: String
    @State var isConnected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.zinc800)
                .cornerRadius(8)
            
            Text(name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isConnected)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .white))
        }
        .padding(16)
        .background(Color.zinc900)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.zinc800, lineWidth: 1))
    }
}
