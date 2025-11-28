import SwiftUI

struct PhaseRewardView: View {
    @EnvironmentObject var model: OnboardingModel
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .socialProof: socialProofView
            case .privacy: privacyView
            default: EmptyView()
            }
        }
    }
    
    // Screen 12: Social Proof
    var socialProofView: some View {
        let reviews: [(name: String, imageName: String, text: String)] = [
            ("Alex Richardson", "alex-richardson", "I finally got clarity on what I should actually focus on. No fluff — just straight direction I wish I had years ago."),
            ("Jena Porter", "jena-porter", "This thing keeps surfacing opportunities I would've completely missed on my own. Honestly wasn't expecting it to be this accurate :)"),
            ("Marcus Delaney", "marcus-delaney", "I thought this would be another 'motivation' app. Nope. It actually shows me what to do next, which is all I needed.")
        ]

        return StepLayout(title: "Trusted by people improving their lives every day") {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(reviews, id: \.name) { review in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(review.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
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
                                                .foregroundColor(Color(hex: "EA965F"))
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

                PulsingStarView()

                Spacer()

                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.zinc500)
                        Text("Your information remains private and secure.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.zinc500)
                            .tracking(0.5)
                    }

                    BottomActionSection(showDivider: false) {
                        model.goToStep(.buildingModel)
                    }
                }
            }
        }
    }
}

struct PulsingStarView: View {
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            // Subtle glow behind star
            Circle()
                .fill(Color.white.opacity(hasAppeared ? 0.08 : 0.0))
                .frame(width: 160, height: 160)
                .blur(radius: 20)

            // Circle border
            Circle()
                .stroke(Color.zinc800, lineWidth: 1)
                .frame(width: 160, height: 160)

            // Star icon
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.white)
                .scaleEffect(hasAppeared ? 1.0 : 0.8)
                .opacity(hasAppeared ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                hasAppeared = true
            }
        }
    }
}
