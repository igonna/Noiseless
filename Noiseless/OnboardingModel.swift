import SwiftUI
import Combine

enum ScreenStep: Int, CaseIterable, Comparable {
    // Part 1: Friendly Opening
    case welcome = 1
    case identity = 2
    case identityDetails = 3

    // Part 2: Location & Skills
    case location = 4
    case skills = 5
    case traits = 6
    
    // Part 3: Motivation Boost
    case graph = 7 // New

    // Part 4: Future Self
    case vision = 8
    case values = 9
    case constraints = 10
    case timeBudget = 11

    // Part 5: Trust + Social Proof
    case socialProof = 12
    case privacy = 13
    case encouragement = 14

    // Part 6: Personalization Ritual
    case buildingModel = 15
    case calibrating = 16
    case pathReady = 17

    // Part 7: Value Preview
    case insightsPreview = 18
    case trialOffer = 19 // New Screen, Merged with Reminder
    
    // Part 8: Hard Paywall + Trial
    case paywall = 20
    case discountOffer = 21
    case subscriptionConfirm = 22

    // Part 9: Final Screens
    case notifications = 23
    case integrations = 24
    case finalWelcome = 25
    case firstSuggestion = 26
    case habitLoop = 27

    // Post-onboarding
    case dashboard = 28
    
    static func < (lhs: ScreenStep, rhs: ScreenStep) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct UserData: Codable {
    var identity: String = ""
    var identityDetail: String = ""
    var location: String = ""
    var skills: [String] = []
    var traits: [String] = []
    var source: [String] = [] // Kept for legacy/future use if needed
    var vision: [String] = []
    var visionDetail: String = "" // New
    var values: [String] = []
    var constraints: [String] = []
    var constraintsDetail: String = "" // New
    var timeBudget: String = ""
}

class OnboardingModel: ObservableObject {
    @Published var currentStep: ScreenStep = .welcome
    @Published var userData: UserData = UserData()
    
    func nextStep() {
        if let next = ScreenStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = next
            }
        }
    }
    
    func prevStep() {
        if let prev = ScreenStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = prev
            }
        }
    }
    
    func goToStep(_ step: ScreenStep) {
        withAnimation {
            currentStep = step
        }
    }
    
    func updateUserData(_ data: PartialUserData) {
        if let identity = data.identity { userData.identity = identity }
        if let identityDetail = data.identityDetail { userData.identityDetail = identityDetail }
        if let location = data.location { userData.location = location }
        if let skills = data.skills { userData.skills = skills }
        if let traits = data.traits { userData.traits = traits }
        if let source = data.source { userData.source = source }
        if let vision = data.vision { userData.vision = vision }
        if let visionDetail = data.visionDetail { userData.visionDetail = visionDetail }
        if let values = data.values { userData.values = values }
        if let constraints = data.constraints { userData.constraints = constraints }
        if let constraintsDetail = data.constraintsDetail { userData.constraintsDetail = constraintsDetail }
        if let timeBudget = data.timeBudget { userData.timeBudget = timeBudget }
    }
}

// Helper struct for partial updates
struct PartialUserData {
    var identity: String?
    var identityDetail: String?
    var location: String?
    var skills: [String]?
    var traits: [String]?
    var source: [String]?
    var vision: [String]?
    var visionDetail: String?
    var values: [String]?
    var constraints: [String]?
    var constraintsDetail: String?
    var timeBudget: String?
}
