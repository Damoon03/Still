import SwiftUI

struct DiscoverView: View {
    var body: some View {
        VStack {
            Spacer()

            NavigationLink(destination: NearbyMemoryView()) {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(StillColor.accent.opacity(0.28 - Double(i) * 0.08), lineWidth: 1)
                            .frame(width: CGFloat(120 + i * 60), height: CGFloat(120 + i * 60))
                    }
                    Circle()
                        .fill(StillColor.accent)
                        .frame(width: 16, height: 16)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: StillSpacing.xs) {
                Text("explore memories near you")
                    .font(StillFont.heading(15))
                    .foregroundStyle(StillColor.ink)
                Text("move around to discover\nstories left by others.")
                    .multilineTextAlignment(.center)
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)
            }
            .padding(.bottom, StillSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .background(StillColor.background)
        .navigationTitle("discover")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(StillColor.ink)
            }
        }
    }
}

#Preview {
    NavigationStack { DiscoverView() }
}
