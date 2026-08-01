import SwiftUI

struct RootView: View {
    @State private var selectedTab: RootTab = .home
    @State private var showingNewMemory = false

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

            Divider().background(StillColor.divider)

            BottomTabBar(selection: $selectedTab) {
                showingNewMemory = true
            }
        }
        .background(StillColor.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewMemory) {
            NewMemoryView()
        }
    }
}

#Preview {
    RootView()
}
