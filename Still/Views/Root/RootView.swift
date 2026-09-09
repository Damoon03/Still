import SwiftUI

struct RootView: View {
    @State private var selectedTab: RootTab = .home
    @State private var showingNewMemory = false

    // Bumped whenever the compose sheet dismisses, so the current
    // tab's .task re-runs and picks up whatever was just saved.
    // Simple over clever: this is a vibe-check build, not a place
    // that needs fine-grained cache invalidation yet.
    @State private var refreshToken = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .map: MapView()
                case .bookmarks: BookmarksView()
                case .profile: ProfileView()
                }
            }
            .id(refreshToken)

            Divider().background(StillColor.divider)

            BottomTabBar(selection: $selectedTab) {
                showingNewMemory = true
            }
        }
        .background(StillColor.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewMemory, onDismiss: {
            refreshToken += 1
        }) {
            NewMemoryView()
        }
    }
}

#Preview {
    RootView()
}

