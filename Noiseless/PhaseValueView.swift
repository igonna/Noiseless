import SwiftUI

struct PhaseValueView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .insightsPreview: insightsPreviewView
            case .trialOffer: trialOfferView
            default: EmptyView()
            }
        }
    }
    
    // Screen 18: Insights Preview
    var insightsPreviewView: some View {
        StepLayout(title: "Save Your Progress", centerContent: true) {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    SignInButton(style: .apple) {
                        model.nextStep()
                    }
                    SignInButton(style: .google) {
                        model.nextStep()
                    }
                }
                .padding(.horizontal, 12)

                Spacer()

                Text("We'll sync your data securely.")
                    .font(.system(size: 12))
                    .foregroundColor(.zinc600)
                    .padding(.bottom, 24)
            }
        }
    }
    
    // Screen 19: Trial Offer
    var trialOfferView: some View {
        StepLayout(
            title: "Try Noiseless free for 3 days.",
            subtitle: "We'll send you a reminder before your free trial ends",
            showProgressBar: false
        ) {
            VStack {
                Spacer()
                
                // Notification Visual
                ZStack {
                    // Glow behind
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .blur(radius: 20)
                        .padding(-16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.zinc800)
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Noiseless")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("now")
                                        .font(.system(size: 12))
                                        .foregroundColor(.zinc500)
                                }
                                
                                Text("Your 3-day trial is ending soon.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.zinc200)
                                
                                Text("We'll remind you 24h before you're charged so you have full control.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc400)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.zinc900.opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.zinc400)
                        
                        Text("No Payment Due Now")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.zinc300)
                    }
                    
                    PrimaryButton(title: "Continue for FREE") {
                        model.nextStep()
                    }
                    
                    Text("Just 46,99 US$ per year (3,91 US$/mo)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

private struct SignInButton: View {
    enum Style {
        case apple
        case google
    }
    
    let style: Style
    let action: () -> Void
    
    private var label: String {
        switch style {
        case .apple: return "Sign in with Apple"
        case .google: return "Sign in with Google"
        }
    }
    
    private var background: Color {
        switch style {
        case .apple: return .white
        case .google: return Color.zinc900
        }
    }
    
    private var foreground: Color {
        style == .apple ? .black : .white
    }
    
    private var borderColor: Color {
        style == .apple ? Color.clear : Color.zinc700
    }
    
    var body: some View {
        Button(action: triggerAction) {
            HStack(spacing: 12) {
                icon
                Text(label)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
            )
            .cornerRadius(28)
            .shadow(color: style == .apple ? Color.white.opacity(0.2) : Color.black.opacity(0.4), radius: 15, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }

    private func triggerAction() {
        HapticManager.tap()
        action()
    }
    
    @ViewBuilder
    private var icon: some View {
        switch style {
        case .apple:
            Image("apple_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
                .offset(y: -2)
        case .google:
            Image("google_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }
}

