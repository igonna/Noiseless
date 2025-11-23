import SwiftUI

// MARK: - Data Models

struct UserProfile: Identifiable {
    let id: String
    // Add other properties as needed
}

struct SignalItem: Identifiable, Equatable {
    let id = UUID()
    let type: String
    let title: String
    let description: String
    let action: String
    
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
            .padding(24)
            .padding(.bottom, 32) // reduce extra bottom padding so last card sits near tab bar
            .frame(maxWidth: 672) // md:max-w-2xl
        }
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
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            // Modern shadow: softer and more diffused
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.04 : 0.06), radius: configuration.isPressed ? 6 : 10, x: 0, y: configuration.isPressed ? 2 : 4)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SignalCard: View {
    let item: SignalItem
    let isSaved: Bool
    let onToggleSave: () -> Void
    
    var body: some View {
        Button(action: {
            // Card tap action
        }) {
            cardContent
        }
        .buttonStyle(SignalCardButtonStyle())
    }
    
    var cardContent: some View {
        let config = item.config
        
        return VStack(alignment: .leading, spacing: 12) {
            // Top Row: Label + Save Button
            HStack(alignment: .top) {
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
                
                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isSaved ? .primary : .secondary)
                }
            }
            
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
                        Image(systemName: config.isChallenge ? "trophy.fill" : "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(config.textColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(actionLabel(for: item.type))
                        .font(.system(size: 12, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundColor(config.isChallenge ? .orange : .secondary)
                    
                    Text(item.action)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground)) // bg-white dark:bg-zinc-900
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(config.borderColor, lineWidth: config.isChallenge ? 2 : 1)
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
