import SwiftUI

// Shared background color constant
private let appBackgroundColor = Color(hex: "09090A")

struct ExamplesView: View {
    @State private var selectedTab: Int = 0
    @State private var lastNonProfileTab: Int = 0
    @State private var showProfile = false
    @State private var todaySignals: [SignalItem] = []
    @State private var isLoadingSignals = true
    @State private var signalsError: String?

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.65)
        // Use a single, dynamic color for both selected and unselected states so icons and labels
        // match in light (dark text) and dark mode (bright text).
        let tabColor = UIColor.label
        appearance.stackedLayoutAppearance.selected.iconColor = tabColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabColor]
        appearance.stackedLayoutAppearance.normal.iconColor = tabColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().isHidden = false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            appBackgroundColor
                .ignoresSafeArea()
                .zIndex(0)

            TabView(selection: $selectedTab) {
                // Tab 1: Today
                TodayView(
                    profile: UserProfile(id: "user1"),
                    data: isLoadingSignals ? nil : todaySignals,
                    onDataLoaded: { _ in },
                    savedItems: [],
                    onToggleSave: { _ in }
                )
                .tag(0)
                .tabItem {
                    Image("tab_calendar")
                        .renderingMode(.template)
                    Text("Today")
                }
                
                // Tab 2: Future
                ZStack {
                    appBackgroundColor
                        .ignoresSafeArea()
                    Text("Future View Placeholder")
                        .foregroundColor(.white)
                }
                .tag(1)
                .tabItem {
                    Image("tab_telescope")
                        .renderingMode(.template)
                    Text("Future")
                }

                // Tab 3: Next Steps
                ZStack {
                    appBackgroundColor
                        .ignoresSafeArea()
                    Text("Next Steps View Placeholder")
                        .foregroundColor(.white)
                }
                .tag(2)
                .tabItem {
                    Image("tab_chess_knight")
                        .renderingMode(.template)
                    Text("Next Steps")
                }

                // Tab 4: Saved
                ZStack {
                    appBackgroundColor
                        .ignoresSafeArea()
                    Text("Saved Items Placeholder")
                        .foregroundColor(.white)
                }
                .tag(3)
                .tabItem {
                    Image("tab_bookmark")
                        .renderingMode(.template)
                    Text("Saved")
                }

                // Profile tab that opens sheet instead of switching content
                Color.clear
                    .tag(4)
                    .tabItem {
                        Image("icon_profile")
                            .renderingMode(.template)
                        Text("Profile")
                    }
            }
            .overlay(alignment: .top) {
                EdgeFadeTop()
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: [.top, .horizontal])
            }
            .onAppear {
                lastNonProfileTab = selectedTab
                fetchTodaySignals()
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 4 {
                    showProfile = true
                    selectedTab = lastNonProfileTab
                } else {
                    lastNonProfileTab = newValue
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileSettingsView()
        }
    }

    private func fetchTodaySignals() {
        Task {
            do {
                isLoadingSignals = true
                signalsError = nil
                todaySignals = try await TodaySignalsService.fetchTodaySignals()
                isLoadingSignals = false
            } catch {
                isLoadingSignals = false
                signalsError = error.localizedDescription
                print("Error fetching today signals: \(error)")
                // Fallback to empty array on error
                todaySignals = []
            }
        }
    }
}
struct EdgeFadeBackground: View {
    var body: some View {
        VStack {
            Spacer()
            EdgeFadeBottom()
        }
        .ignoresSafeArea(edges: [.horizontal, .bottom])
    }
}

struct EdgeFadeTop: View {
    var body: some View {
        LinearGradient(
            colors: [appBackgroundColor, appBackgroundColor.opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 96)
    }
}

struct EdgeFadeBottom: View {
    var body: some View {
        LinearGradient(
            colors: [appBackgroundColor.opacity(0), appBackgroundColor],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 96)
    }
}

struct ExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ExamplesView()
    }
}
