import SwiftUI

struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Group {
                // Part 1: Opening (Screens 1-3)
                if model.currentStep >= .welcome && model.currentStep <= .identityDetails {
                    PhaseTrustView()
                }
                
                // Part 2, 3 & 4: Location, Skills, Graph, Future Self (Screens 4-11)
                else if model.currentStep >= .location && model.currentStep <= .timeBudget {
                    PhaseDataView()
                }
                
                // Part 5: Trust + Social Proof (Screens 12-14)
                else if model.currentStep >= .socialProof && model.currentStep <= .encouragement {
                    PhaseRewardView()
                }
                
                // Part 6: Ritual (Screens 15-17)
                else if model.currentStep >= .buildingModel && model.currentStep <= .pathReady {
                    PhaseRitualView()
                }
                
                // Part 7: Value Preview (Screens 18-19)
                else if model.currentStep >= .insightsPreview && model.currentStep <= .trialOffer {
                    PhaseValueView()
                }
                
                // Part 8: Hard Paywall + Trial (Screens 20-22)
                else if model.currentStep >= .paywall && model.currentStep <= .subscriptionConfirm {
                    PhasePaywallView()
                }
                
                // Part 9: Final Screens (Screens 23-28)
                else if model.currentStep >= .notifications {
                    PhaseFinalView()
                }
            }
            .environmentObject(model)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: model.currentStep)
        }
        .statusBar(hidden: true)
    }
}
