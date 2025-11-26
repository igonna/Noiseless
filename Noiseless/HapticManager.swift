import UIKit

enum HapticType {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

enum HapticManager {
    static func trigger(_ type: HapticType = .impact(.medium)) {
        switch type {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .notification(let notificationType):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(notificationType)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    static func tap() {
        trigger(.impact(.soft))
    }
    
    static func lightTap() {
        trigger(.selection)
    }
}
