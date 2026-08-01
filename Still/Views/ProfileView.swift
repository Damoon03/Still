import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: StillSpacing.lg) {
                Circle()
                    .fill(StillColor.surfaceElevated)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Image(systemName: "person")
                            .font(.system(size: 32))
                            .foregroundStyle(StillColor.inkSecondary)
                    )

                VStack(spacing: 2) {
                    Text("damoon")
                        .font(StillFont.heading(17))
                        .foregroundStyle(StillColor.ink)
                    Text("@damoon")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)
                }

                HStack(spacing: StillSpacing.lg) {
                    VStack(spacing: 2) {
                        Text("23")
                            .font(StillFont.heading(16))
                            .foregroundStyle(StillColor.ink)
                        Text("memories")
                            .font(StillFont.caption(11))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                    VStack(spacing: 2) {
                        Text("14")
                            .font(StillFont.heading(16))
                            .foregroundStyle(StillColor.ink)
                        Text("places")
                            .font(StillFont.caption(11))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                }

                Spacer()
            }
            .padding(.top, StillSpacing.xl)
            .padding(StillSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(StillColor.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: FriendsView()) {
                        Image(systemName: "person.2")
                            .foregroundStyle(StillColor.ink)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(StillColor.ink)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
