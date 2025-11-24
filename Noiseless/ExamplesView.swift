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
                        SignalItem(
                            type: "news_essence",
                            title: "Global Market Shift",
                            description: "Asian markets rally as the quantum-backed tech sector rebounds, while EU regulators float a unified carbon border credit that could rewrite supply chains this decade. Analysts expect secondary effects on dollar liquidity and frontier currencies over the next six quarters.",
                            action: "Read Summary"
                        ),
                        SignalItem(
                            type: "opportunity",
                            title: "New AI Grant",
                            description: "Applications open for $50k innovation grants focused on sovereign AI safety co-processors. Cohort includes on-device LLM guardrails, privacy-preserving telemetry, and post-quantum key rotation. Ideal for teams ready to ship within 9 months.",
                            action: "Apply Now"
                        ),
                        SignalItem(
                            type: "shift",
                            title: "Remote Work Trends",
                            description: "Hybrid defaults are giving way to hub-and-spoke micro-offices. Firms shifting to 3-2 rhythms report 12% higher retention, but capex is reallocating to neighborhood labs, AR-first onboarding, and asynchronous decision protocols.",
                            action: "View Report"
                        ),
                        SignalItem(
                            type: "opportunity",
                            title: "Climate Resilience Bonds",
                            description: "Cities are issuing tokenized green bonds that auto-adjust coupons based on verified resilience milestones—think microgrid uptime, blue-roof deployments, and heat dome response drills—creating a new alpha surface for muni desks.",
                            action: "See Deal Flow"
                        ),
                        SignalItem(
                            type: "mental_model",
                            title: "Entropy Budgeting",
                            description: "Leaders are treating organizational entropy as a balance sheet item: instrumenting decision latency, refactoring meetings into API calls, and reserving ‘noise allowances’ for exploratory bets instead of ad-hoc firefights.",
                            action: "Practice It"
                        ),
                        SignalItem(
                            type: "news_essence",
                            title: "Biofabrication Sprint",
                            description: "A tri-continental coalition just open-sourced wet-lab automation recipes for collagen scaffolds. Early pilots cut prototype cycles from 6 weeks to 4 days, hinting at consumer-grade custom prosthetics by late 2027.",
                            action: "Track Release"
                        ),
                        SignalItem(
                            type: "shift",
                            title: "Logistics Autonomy",
                            description: "Port operators are phasing in autonomous yard orchestration. Initial trials show 18% faster turn times and a 30% drop in idling emissions. Expect insurer policies to update once the second safety audit wave lands in Q1.",
                            action: "View Brief"
                        ),
                        SignalItem(
                            type: "opportunity",
                            title: "Learning Wallets",
                            description: "Governments piloting ‘learning wallets’ that stipend verified upskilling hours with transferable micro-credentials. Early adopters bundle local employer guarantees, shrinking talent discovery cycles for hard-to-fill roles.",
                            action: "Explore Pilot"
                        )
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
            .overlay(alignment: .top) {
                EdgeFadeTop()
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: [.top, .horizontal])
            }
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
