import SwiftUI

struct PhaseRewardView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .socialProof: socialProofView
            case .privacy: privacyView
            case .encouragement: encouragementView
            default: EmptyView()
            }
        }
    }
    
    // Screen 12: Social Proof
    var socialProofView: some View {
        StepLayout(title: "Join thousands of others.", subtitle: "You are not alone in this journey.") {
            VStack(spacing: 24) {
                Spacer()
                
                // Testimonial Card 1
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                        }
                    }
                    Text("“This app completely changed how I approach my day. The insights are spot on.”")
                        .font(.system(size: 16))
                        .foregroundColor(.zinc200)
                        .italic()
                    Text("- Sarah K.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.zinc500)
                }
                .padding(20)
                .background(Color.zinc900)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.zinc800, lineWidth: 1))
                
                // Testimonial Card 2
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                        }
                    }
                    Text("“Finally, something that understands my pace and goals. Highly recommended.”")
                        .font(.system(size: 16))
                        .foregroundColor(.zinc200)
                        .italic()
                    Text("- Michael R.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.zinc500)
                }
                .padding(20)
                .background(Color.zinc900)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.zinc800, lineWidth: 1))
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Screen 13: Privacy
    var privacyView: some View {
        StepLayout(title: "Your privacy is our priority.", subtitle: "We protect your data with industry-standard encryption.") {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.zinc200)
                
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Your data is encrypted and stored securely.")
                            .foregroundColor(.zinc400)
                    }
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("We never sell your personal information.")
                            .foregroundColor(.zinc400)
                    }
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("You have full control over your data.")
                            .foregroundColor(.zinc400)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                PrimaryButton(title: "I Understand") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Screen 14: Encouragement
    var encouragementView: some View {
        StepLayout(centerContent: true) {
            VStack(spacing: 24) {
                Spacer()
                
                Text("You're doing great.")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We're almost ready to build your personalized plan.")
                    .font(.system(size: 18))
                    .foregroundColor(.zinc400)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                PrimaryButton(title: "Let's Build It") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
}
