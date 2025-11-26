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
        StepLayout(title: "Here is what we found.", subtitle: "Based on your profile:") {
            VStack(spacing: 24) {
                // Insight Card 1
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                        .padding(12)
                        .background(Color.zinc800)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("High Potential for Growth")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Your combination of skills and traits suggests you thrive in structured environments but need help with consistency.")
                            .font(.system(size: 16))
                            .foregroundColor(.zinc400)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(20)
                .background(Color.zinc900)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.zinc800, lineWidth: 1))
                
                // Insight Card 2
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .padding(12)
                        .background(Color.zinc800)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended Pace: \(model.userData.timeBudget.components(separatedBy: " — ").first ?? "Steady")")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("We've adjusted your learning path to match your desired pace. Small daily actions will compound over time.")
                            .font(.system(size: 16))
                            .foregroundColor(.zinc400)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(20)
                .background(Color.zinc900)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.zinc800, lineWidth: 1))
                
                Spacer()
                
                PrimaryButton(title: "Unlock My Plan") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
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
