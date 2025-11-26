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
        let reviews: [(name: String, initial: String, text: String, color: Color)] = [
            ("Alex Richardson", "A", "I finally got clarity on what I should actually focus on. No fluff — just straight direction I wish I had years ago.", Color.blue),
            ("Jena Porter", "J", "This thing keeps surfacing opportunities I would’ve completely missed on my own. Honestly wasn’t expecting it to be this accurate :)", Color.green),
            ("Marcus Delaney", "M", "I thought this would be another ‘motivation’ app. Nope. It actually shows me what to do next, which is all I needed.", Color.purple)
        ]
        
        return StepLayout(title: "Trusted by people improving their lives every day") {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(reviews, id: \.name) { review in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Text(review.initial)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(review.color)
                                        .clipShape(Circle())

                                    Text(review.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }

                                Text(review.text)
                                    .font(.system(size: 15))
                                    .foregroundColor(.zinc300)
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .background(Color.zinc950)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .cornerRadius(20)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Spacer()

                BottomActionSection {
                    model.nextStep()
                }
            }
        }
    }
    
    // Screen 13: Privacy
    var privacyView: some View {
        StepLayout(title: "Time to generate your custom plan!", centerContent: true) {
            VStack(spacing: 32) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 160, height: 160)
                        .blur(radius: 10)
                    Circle()
                        .stroke(Color.zinc800, lineWidth: 1)
                        .frame(width: 160, height: 160)
                    Image(systemName: "sparkles")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                }
                
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.zinc500)
                    Text("Your information remains private and secure.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.zinc500)
                        .tracking(0.5)
                }
                
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }

    // Screen 14: Encouragement (Skipped - directly goes to ritual in React implementation)
    // Note: React implementation skips this screen entirely and jumps from privacy to buildingModel
    var encouragementView: some View {
        StepLayout(title: "You're ready!", centerContent: true) {
            VStack(spacing: 32) {
                Spacer()
                Text("Let's build your personalized path.")
                    .font(.system(size: 18))
                    .foregroundColor(.zinc400)
                    .multilineTextAlignment(.center)
                Spacer()
                PrimaryButton(title: "Continue") {
                    model.goToStep(.buildingModel)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
