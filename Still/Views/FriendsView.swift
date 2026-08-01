import SwiftUI

struct FriendsView: View {
    private let friends = Friend.dummyData

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(friends) { friend in
                    VStack(spacing: 0) {
                        HStack {
                            Circle()
                                .fill(StillColor.surfaceElevated)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "person")
                                        .foregroundStyle(StillColor.inkSecondary)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friend.name)
                                    .font(StillFont.body(14))
                                    .foregroundStyle(StillColor.ink)
                                Text("\(friend.memoryCount) memories")
                                    .font(StillFont.caption(12))
                                    .foregroundStyle(StillColor.inkSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(StillColor.inkSecondary)
                        }
                        .padding(.vertical, StillSpacing.sm + 2)

                        Divider().background(StillColor.divider)
                    }
                }
            }
            .padding(StillSpacing.md)
        }
        .background(StillColor.background)
        .navigationTitle("friends")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "plus")
                    .foregroundStyle(StillColor.ink)
            }
        }
    }
}

#Preview {
    NavigationStack { FriendsView() }
}
