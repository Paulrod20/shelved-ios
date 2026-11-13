import SwiftUI

enum AppTab: String {
    case backlog, search, stats, profile
}

/// The four main tabs. The native tab bar adopts Liquid Glass on its own; nothing custom is drawn.
struct MainTabView: View {
    @SceneStorage("selectedTab") private var selectedTab = AppTab.backlog
    @State private var statsViewModel: StatsViewModel

    init(container: AppContainer) {
        _statsViewModel = State(initialValue: StatsViewModel(library: container.library))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Backlog", systemImage: "gamecontroller", value: .backlog) {
                UpcomingTab(title: "Backlog", systemImage: "gamecontroller")
            }
            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                UpcomingTab(title: "Search", systemImage: "magnifyingglass")
            }
            Tab("Stats", systemImage: "chart.line.uptrend.xyaxis", value: .stats) {
                StatsView(viewModel: statsViewModel)
            }
            Tab("Profile", systemImage: "person", value: .profile) {
                UpcomingTab(title: "Profile", systemImage: "person")
            }
        }
        // The modifier applies to the whole TabView, so it is switched per tab to keep it Backlog-only.
        .tabBarMinimizeBehavior(selectedTab == .backlog ? .onScrollDown : .never)
    }
}

/// Stand-in for tabs that later slices build (Backlog: 3, Search: 4, Profile: 5).
private struct UpcomingTab: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: systemImage, description: Text("Coming soon."))
                .foregroundStyle(.textMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.appBackground)
                .navigationTitle(title)
        }
    }
}
