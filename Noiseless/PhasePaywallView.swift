import SwiftUI

struct PhasePaywallView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var selectedPlan: PlanType = .yearly
    
    enum PlanType {
        case monthly, yearly
    }
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .paywall: paywallView
            case .discountOffer: discountOfferView
            case .subscriptionConfirm: subscriptionConfirmView
            default: EmptyView()
            }
        }
    }
    
    // ... (rest of the view content)

    // Screen 20: Hard Paywall + Trial
    var paywallView: some View {
        StepLayout(title: "Unlock Your Noiseless Advantage", showProgressBar: false, centerTitle: true) {
            VStack(spacing: 0) {
                // Features List
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(text: "Daily insights tailored to your goals")
                    FeatureRow(text: "Smart opportunities matched to your skills")
                    FeatureRow(text: "Clear next steps you can act on immediately")
                    FeatureRow(text: "Real shifts that actually affect your future")
                    FeatureRow(text: "Always adapting as you grow")
                }
                .padding(.top, 20)

                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    // Plan Selection
                    HStack(spacing: 16) {
                        PlanSelectionCard(
                            title: "MONTHLY",
                            price: "11,99 US$/mo",
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }

                        PlanSelectionCard(
                            title: "YEARLY",
                            price: "3,91 US$/mo",
                            isSelected: selectedPlan == .yearly,
                            badgeText: "3 DAYS FREE"
                        ) {
                            selectedPlan = .yearly
                        }
                    }

                    // Bottom section
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image("shield_check_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)

                            Text(selectedPlan == .yearly ? "No Payment Due Now" : "Cancel Anytime")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.zinc300)
                        }

                        PrimaryButton(
                            title: selectedPlan == .yearly ? "Start My 3-Day Free Trial" : "Unlock Full Access",
                            height: 56,
                            enableHaptics: false,
                            enablePressAnimation: true
                        ) {
                            model.goToStep(.notifications)
                        }
                        .shadow(color: Color.white.opacity(0.1), radius: 20, x: 0, y: 10)

                        Text(selectedPlan == .yearly ? "3 days free, then 46,99 US$ per year (3,91US$/mo)" : "Just 11,99 US$ per month")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.zinc500)
                    }
                }
                .padding(.bottom, 1)
            }
        }
    }
    
    // Screen 21: Discount Offer
    var discountOfferView: some View {
        StepLayout(showProgressBar: false, centerContent: true) {
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Text("Want 20% off your first year?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            model.goToStep(.paywall)
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.zinc500)
                        }
                    }
                    
                    Text("Optional offer — no pressure.")
                        .font(.system(size: 16))
                        .foregroundColor(.zinc400)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Claim Discount") {
                            model.goToStep(.notifications)
                        }
                        
                        PrimaryButton(
                            title: "Skip",
                            variant: .secondary
                        ) {
                            model.goToStep(.paywall)
                        }
                    }
                }
                .padding(24)
                .background(Color.zinc900)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Spacer()
            }
        }
    }
    
    // Screen 22: Subscription Confirm
    var subscriptionConfirmView: some View {
        StepLayout(centerContent: true) {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("You're all set!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your journey begins now.")
                    .font(.system(size: 18))
                    .foregroundColor(.zinc400)
                
                Spacer()
                
                PrimaryButton(title: "Enter App") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct PlanSelectionCard: View {
    let title: String
    let price: String
    let isSelected: Bool
    let badgeText: String?
    let action: () -> Void
    @State private var badgeHeight: CGFloat = 0
    
    init(
        title: String,
        price: String,
        isSelected: Bool,
        badgeText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.price = price
        self.isSelected = isSelected
        self.badgeText = badgeText
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            cardContents
                .overlay(alignment: .top) {
                    if let badgeText {
                        badge(text: badgeText)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            badgeHeight = proxy.size.height
                                        }
                                        .onChange(of: proxy.size.height) { newValue in
                                            badgeHeight = newValue
                                        }
                                }
                            )
                            .offset(y: -(badgeHeight / 2))
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title.capitalized) plan")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(.isButton)
    }
    
    private var cardContents: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .tracking(1)
                .foregroundColor(.white)
            
            Text(price)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .animation(nil, value: isSelected)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.zinc900 : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white : Color.zinc800, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
    
    private func badge(text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1)
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white))
            .shadow(radius: 4)
    }
}

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 18, height: 18)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
            }
            .padding(.top, 1)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.zinc100)
                .lineSpacing(2)
        }
    }
}
