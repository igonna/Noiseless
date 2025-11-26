import SwiftUI

struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()

    var body: some View {
        ZStack(alignment: .top) {
            // Persistent background
            Color.zinc950
                .ignoresSafeArea()

            // Content with instant switching (no animations)
            currentPhaseView
                .environmentObject(model)

            // Persistent header (back button + progress bar)
            persistentHeader
                .environmentObject(model)
        }
        .statusBar(hidden: true)
    }

    @ViewBuilder
    private var persistentHeader: some View {
        HStack(spacing: 16) {
            if shouldShowBackButton {
                let isMinimal = model.currentStep == .trialOffer || model.currentStep == .paywall
                Button(action: {
                    model.prevStep()
                }) {
                    Image(systemName: isMinimal ? "chevron.left" : "arrow.left")
                        .font(.system(size: isMinimal ? 28 : 20, weight: .medium))
                        .foregroundColor(isMinimal ? .zinc500 : .zinc400)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }

            if shouldShowProgressBar {
                ProgressBar(currentStep: model.currentStep)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var shouldShowBackButton: Bool {
        !hideBackButtonSteps.contains(model.currentStep) &&
        model.currentStep.rawValue > ScreenStep.welcome.rawValue
    }

    private var shouldShowProgressBar: Bool {
        !hideProgressBarSteps.contains(model.currentStep)
    }

    private var hideBackButtonSteps: Set<ScreenStep> {
        [.notifications, .finalWelcome, .buildingModel, .calibrating, .pathReady]
    }

    private var hideProgressBarSteps: Set<ScreenStep> {
        [.welcome, .notifications, .finalWelcome, .buildingModel, .calibrating, .pathReady,
         .trialOffer, .paywall, .discountOffer, .subscriptionConfirm]
    }

    @ViewBuilder
    private var currentPhaseView: some View {
        // Part 1: Opening (Screens 1-3)
        if model.currentStep >= .welcome && model.currentStep <= .identityDetails {
            PhaseTrustView()
        }
        // Part 2, 3 & 4: Location, Skills, Graph, Future Self (Screens 4-11)
        else if model.currentStep >= .location && model.currentStep <= .timeBudget {
            PhaseDataView()
        }
        // Part 5: Trust + Social Proof (Screens 12-13)
        else if model.currentStep >= .socialProof && model.currentStep <= .privacy {
            PhaseRewardView()
        }
        // Part 6: Ritual (Screens 14-16)
        else if model.currentStep >= .buildingModel && model.currentStep <= .pathReady {
            PhaseRitualView()
        }
        // Part 7: Value Preview (Screens 17-18)
        else if model.currentStep >= .insightsPreview && model.currentStep <= .trialOffer {
            PhaseValueView()
        }
        // Part 8: Hard Paywall + Trial (Screens 19-21)
        else if model.currentStep >= .paywall && model.currentStep <= .subscriptionConfirm {
            PhasePaywallView()
        }
        // Part 9: Final Screens (Screens 22-27)
        else {
            PhaseFinalView()
        }
    }
}
