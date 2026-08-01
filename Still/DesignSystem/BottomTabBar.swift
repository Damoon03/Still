import SwiftUI

enum RootTab {
    case home, map, bookmarks, profile
}

struct BottomTabBar: View {
    @Binding var selection: RootTab
    let onCompose: () -> Void

    var body: some View {
        HStack {
            tabButton(.home, icon: "house")
            Spacer()
            tabButton(.map, icon: "map")
            Spacer()
            composeButton
            Spacer()
            tabButton(.bookmarks, icon: "bookmark")
            Spacer()
            tabButton(.profile, icon: "person")
        }
        .padding(.horizontal, StillSpacing.lg)
        .padding(.vertical, StillSpacing.sm + 4)
        .background(StillColor.background)
    }

    private func tabButton(_ tab: RootTab, icon: String) -> some View {
        Button {
            selection = tab
        } label: {
            Image(systemName: selection == tab ? icon + ".fill" : icon)
                .font(.system(size: 20))
                .foregroundStyle(selection == tab ? StillColor.accent : StillColor.inkSecondary)
        }
    }

    private var composeButton: some View {
        Button(action: onCompose) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(StillColor.background)
                .frame(width: 48, height: 48)
                .background(StillColor.accent)
                .clipShape(Circle())
        }
    }
}
