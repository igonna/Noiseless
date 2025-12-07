import SwiftUI
import Combine

// Shared background color constant
private let appBackgroundColor = Color(hex: "09090A")

// MARK: - Custom Bookmark Icon
// Based on svg-icons/bookmark.svg: m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z

struct BookmarkIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / 24
        let scaleY = rect.height / 24

        path.move(to: CGPoint(x: 19 * scaleX, y: 21 * scaleY))
        path.addLine(to: CGPoint(x: 12 * scaleX, y: 17 * scaleY))
        path.addLine(to: CGPoint(x: 5 * scaleX, y: 21 * scaleY))
        path.addLine(to: CGPoint(x: 5 * scaleX, y: 5 * scaleY))
        path.addArc(tangent1End: CGPoint(x: 5 * scaleX, y: 3 * scaleY), tangent2End: CGPoint(x: 7 * scaleX, y: 3 * scaleY), radius: 2 * min(scaleX, scaleY))
        path.addLine(to: CGPoint(x: 17 * scaleX, y: 3 * scaleY))
        path.addArc(tangent1End: CGPoint(x: 19 * scaleX, y: 3 * scaleY), tangent2End: CGPoint(x: 19 * scaleX, y: 5 * scaleY), radius: 2 * min(scaleX, scaleY))
        path.addLine(to: CGPoint(x: 19 * scaleX, y: 21 * scaleY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Data Models

struct UserProfile: Identifiable {
    let id: String
    // Add other properties as needed
}

struct SignalItem: Identifiable, Equatable {
    let id: String
    let type: String
    let title: String
    let description: String
    let action: String

    // Convenience initializer for local/test data without explicit id
    init(id: String = UUID().uuidString, type: String, title: String, description: String, action: String) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.action = action
    }

    // Equatable conformance for efficient updates
    static func == (lhs: SignalItem, rhs: SignalItem) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type && lhs.title == rhs.title
    }
}

struct SavedItem: Identifiable {
    let id: String
    let title: String
}

// MARK: - Configuration Helper

struct SignalConfig {
    let icon: String // SF Symbol name
    let label: String
    let bgColor: Color
    let textColor: Color
    let borderColor: Color
    let isChallenge: Bool
    
    // Helper to get color from hex or standard colors.
    // In a real app, these would likely be defined in an Asset catalog.
    // For this standalone file, we use system colors with opacity/modifiers.
}

extension SignalItem {
    var config: SignalConfig {
        switch type {
        case "shift":
            return SignalConfig(
                icon: "globe",
                label: "World Shift",
                bgColor: Color(uiColor: .systemGray6),
                textColor: .secondary,
                borderColor: Color(uiColor: .systemGray5),
                isChallenge: false
            )
        case "news_essence":
            return SignalConfig(
                icon: "newspaper",
                label: "News Essence",
                bgColor: Color.indigo.opacity(0.1),
                textColor: .indigo,
                borderColor: Color.indigo.opacity(0.2),
                isChallenge: false
            )
        case "opportunity":
            return SignalConfig(
                icon: "bolt.fill",
                label: "Opportunity Window",
                bgColor: Color.green.opacity(0.1), // Emerald approximation
                textColor: .green,
                borderColor: Color.green.opacity(0.2),
                isChallenge: false
            )
        case "hype_hot":
            return SignalConfig(
                icon: "flame.fill",
                label: "What's Hot (24h)",
                bgColor: Color.red.opacity(0.1), // Rose approximation
                textColor: .red,
                borderColor: Color.red.opacity(0.2),
                isChallenge: false
            )
        case "micro_challenge":
            return SignalConfig(
                icon: "trophy.fill",
                label: "Micro-Challenge",
                bgColor: Color.orange.opacity(0.1), // Amber approximation
                textColor: .orange,
                borderColor: Color.orange.opacity(0.2),
                isChallenge: true
            )
        case "shortcut":
            return SignalConfig(
                icon: "clock.fill",
                label: "Ecosystem Shortcut",
                bgColor: Color.blue.opacity(0.1),
                textColor: .blue,
                borderColor: Color.blue.opacity(0.2),
                isChallenge: false
            )
        case "mental_model":
            return SignalConfig(
                icon: "brain.head.profile",
                label: "Mental Model",
                bgColor: Color.purple.opacity(0.1),
                textColor: .purple,
                borderColor: Color.purple.opacity(0.2),
                isChallenge: false
            )
        default:
            return SignalConfig(
                icon: "globe",
                label: "Signal",
                bgColor: Color(uiColor: .systemGray6),
                textColor: .secondary,
                borderColor: Color(uiColor: .systemGray5),
                isChallenge: false
            )
        }
    }
}

// MARK: - Main View

struct TodayView: View {
    let profile: UserProfile
    let data: [SignalItem]?
    let onDataLoaded: ([SignalItem]) -> Void
    let savedItems: [SavedItem]
    let onToggleSave: (SignalItem) -> Void
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                if isLoading {
                    loadingView
                } else {
                    signalsList
                }
            }
            .padding(16)
            .padding(.bottom, 32) // reduce extra bottom padding so last card sits near tab bar
            .frame(maxWidth: .infinity)
        }
        .background(appBackgroundColor)
        .onAppear {
            loadData()
        }
        .onChange(of: data) { newValue in
            if newValue != nil {
                isLoading = false
            }
        }
    }
    
    private func loadData() {
        if let existingData = data {
            isLoading = false
            return
        }
        
        isLoading = true
        
        // Simulate async fetch
        Task {
            // In a real app, call fetchTodayEssence(profile) here
            // For now, we assume the parent handles the actual fetch and passes data back via onDataLoaded
            // or updates the `data` binding.
            // This logic mirrors the React useEffect.
            
            // Simulating network delay for demo purposes if needed,
            // but the React code calls fetchTodayEssence.
            // Since we don't have the service, we rely on the parent to update `data`.
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16))
                Text("Daily Intelligence")
                    .font(.system(size: 14, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(1) // tracking-wider
            }
            .foregroundColor(.secondary) // text-ai-subtle
            
            Text("The World in 1 Minute.")
                .font(.system(size: 30, weight: .semibold)) // text-3xl
                .foregroundColor(.primary) // text-ai-black
            
            Text("Your daily signals, live hype, and actions.")
                .foregroundColor(.secondary) // text-ai-subtle
        }
        .padding(.bottom, 32) // mb-8
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 150, height: 32)
            
            ForEach(0..<6) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(height: 128)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
                    )
            }
        }
        .redacted(reason: .placeholder) // animate-pulse equivalent
    }
    
    private var signalsList: some View {
        VStack(spacing: 20) {
            ForEach(data ?? []) { item in
                SignalCard(item: item, isSaved: isSaved(item), onToggleSave: { onToggleSave(item) })
            }
        }
    }
    
    private func isSaved(_ item: SignalItem) -> Bool {
        savedItems.contains { $0.title == item.title }
    }
}

struct SignalCardButtonStyle: ButtonStyle {
    let onHaptic: () -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.02 : 1.0)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.06), radius: configuration.isPressed ? 12 : 10, x: 0, y: configuration.isPressed ? 6 : 4)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    // Delay haptic to match when scale animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        HapticManager.tap()
                        // Trigger action after haptic
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            onHaptic()
                        }
                    }
                }
            }
    }
}

// MARK: - Animated Word

struct AnimatedWord: Identifiable {
    let id = UUID()
    let text: String
    var opacity: Double = 0.0
}

struct AnimatedTextView: View {
    let words: [AnimatedWord]

    var body: some View {
        Text(buildAttributedText())
    }

    private func buildAttributedText() -> AttributedString {
        var result = AttributedString()

        for (index, word) in words.enumerated() {
            var wordText = AttributedString(word.text)
            wordText.foregroundColor = .secondary.opacity(word.opacity)
            result += wordText

            // Add space after word (except for last word)
            if index < words.count - 1 {
                result += AttributedString(" ")
            }
        }

        return result
    }
}

// MARK: - Pulsing Dot

struct PulsingDot: View {
    @State private var isPulsing = false
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Animated Thinking Text

struct AnimatedThinkingText: View {
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("Thinking" + String(repeating: ".", count: dotCount))
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % 4
            }
    }
}

struct SignalCard: View {
    @EnvironmentObject var authController: AuthController

    let item: SignalItem
    let isSaved: Bool
    let onToggleSave: () -> Void

    @State private var actionResult: String?
    @State private var animatedWords: [AnimatedWord] = []
    @State private var isLoadingAction = false
    @State private var hasRequestedAction = false

    var body: some View {
        Button(action: {
            // Action is triggered by button style after haptic
        }) {
            cardContent
        }
        .buttonStyle(SignalCardButtonStyle(onHaptic: handleCardTap))
    }

    private func handleCardTap() {
        // Only send request once
        guard !hasRequestedAction else { return }

        hasRequestedAction = true

        Task {
            do {
                isLoadingAction = true
                let result = try await TodaySignalsService.performSignalAction(signalId: item.id, authController: authController)
                actionResult = result
                isLoadingAction = false
                // Start typewriter animation
                await animateText(result)
            } catch {
                print("Error performing signal action: \(error)")
                isLoadingAction = false
            }
        }
    }

    private func animateText(_ fullText: String) async {
        animatedWords = []
        let words = fullText.split(separator: " ")

        for word in words {
            // Add new word with 0 opacity
            let newWord = AnimatedWord(text: String(word), opacity: 0.0)
            animatedWords.append(newWord)

            // Animate opacity to 1
            withAnimation(.easeIn(duration: 0.3)) {
                if let index = animatedWords.firstIndex(where: { $0.id == newWord.id }) {
                    animatedWords[index].opacity = 1.0
                }
            }

            // Wait before next word (70ms for smoother effect)
            try? await Task.sleep(nanoseconds: 70_000_000)
        }
    }
    
    var cardContent: some View {
        let config = item.config
        
        return VStack(alignment: .leading, spacing: 12) {
            // Top Row: Label + Save Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: config.icon)
                        .font(.system(size: 14))
                    Text(config.label)
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(config.bgColor)
                .foregroundColor(config.textColor)
                .cornerRadius(999)

                if item.type == "hype_hot" {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.75))
                            .frame(width: 10, height: 10)
                            .scaleEffect(1.5)
                            .opacity(0.5)
                            // Animation would go here
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }
                }

                Spacer()

                Button(action: {
                    onToggleSave()
                }) {
                    ZStack {
                        if isSaved {
                            BookmarkIcon()
                                .fill(Color(hex: "3F3F41"))
                                .frame(width: 20, height: 20)
                        } else {
                            BookmarkIcon()
                                .stroke(Color(hex: "3F3F41"), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, -4)
            
            // Title
            Text(item.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Description
            Text(item.description)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .systemGray))
                .lineSpacing(4) // relaxed leading
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .background(config.isChallenge ? Color.orange.opacity(0.2) : Color(uiColor: .systemGray6))

            // Bottom Row: Action
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(config.bgColor)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Group {
                            if isLoadingAction {
                                PulsingDot(color: config.textColor)
                            } else {
                                Image(systemName: config.isChallenge ? "trophy.fill" : "arrow.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(config.textColor)
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(actionLabel(for: item.type))
                        .font(.system(size: 12, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundColor(config.isChallenge ? .orange : .secondary)

                    if isLoadingAction {
                        AnimatedThinkingText()
                    } else if actionResult != nil {
                        AnimatedTextView(words: animatedWords)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(item.action)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(hex: "151516"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(config.borderColor, lineWidth: 1)
        )
    }
    
    private func actionLabel(for type: String) -> String {
        switch type {
        case "news_essence": return "Takeaway"
        case "micro_challenge": return "Your Mission"
        default: return "Action"
        }
    }
}

// MARK: - Preview

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(
            profile: UserProfile(id: "1"),
            data: [
                SignalItem(type: "shift", title: "AI Revolution", description: "AI is changing everything.", action: "Read more"),
                SignalItem(type: "hype_hot", title: "New Framework", description: "Everyone is talking about it.", action: "Check it out"),
                SignalItem(type: "micro_challenge", title: "Daily Goal", description: "Code for 1 hour.", action: "Start now")
            ],
            onDataLoaded: { _ in },
            savedItems: [],
            onToggleSave: { _ in }
        )
        .preferredColorScheme(.light)
        
        TodayView(
            profile: UserProfile(id: "1"),
            data: nil, // Loading state
            onDataLoaded: { _ in },
            savedItems: [],
            onToggleSave: { _ in }
        )
        .preferredColorScheme(.dark)
    }
}
