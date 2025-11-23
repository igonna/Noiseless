import SwiftUI

struct ExamplesView: View {
    @State private var selectedTab: Int = 0
    @State private var lastNonProfileTab: Int = 0
    @State private var showProfile = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.65)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().isHidden = false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            EdgeFadeBackground()
                .allowsHitTesting(false)
                .zIndex(0)

            TabView(selection: $selectedTab) {
                // Tab 1: Today
                TodayView(
                    profile: UserProfile(id: "user1"),
                    data: [
                        SignalItem(type: "news_essence", title: "Global Market Shift", description: "Asian markets rally as tech sector rebounds.", action: "Read Summary"),
                        SignalItem(type: "opportunity", title: "New AI Grant", description: "Applications open for $50k innovation grants.", action: "Apply Now"),
                        SignalItem(type: "shift", title: "Remote Work Trends", description: "Hybrid models becoming the new standard.", action: "View Report")
                    ],
                    onDataLoaded: { _ in },
                    savedItems: [],
                    onToggleSave: { _ in }
                )
                .tag(0)
                .tabItem {
                    Image("tab_calendar")
                    Text("Today")
                }
                
                // Tab 2: Trends
                Text("Trends View Placeholder")
                    .tag(1)
                    .tabItem {
                        Image("tab_activity")
                        Text("Trends")
                    }
                
                // Tab 3: Growth/Market
                Text("Growth View Placeholder")
                    .tag(2)
                    .tabItem {
                        Image("tab_trending")
                        Text("Growth")
                    }
                
                // Tab 4: Saved
                Text("Saved Items Placeholder")
                    .tag(3)
                    .tabItem {
                        Image("tab_bookmark")
                        Text("Saved")
                    }

                // Profile tab that opens sheet instead of switching content
                Color.clear
                    .tag(4)
                    .tabItem {
                        Image("icon_profile")
                        Text("Profile")
                    }
            }
            .background(Color(.systemBackground))
            .onAppear { lastNonProfileTab = selectedTab }
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
}
struct EdgeFadeBackground: View {
    var body: some View {
        ZStack {
            VStack {
                EdgeFadeTop()
                Spacer()
            }
            VStack {
                Spacer()
                EdgeFadeBottom()
            }
        }
        .ignoresSafeArea()
    }
}

struct EdgeFadeTop: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 96)
    }
}

struct EdgeFadeBottom: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
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
