import SwiftUI

struct NearbyMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: StillSpacing.lg) {
            Card {
                VStack(alignment: .leading, spacing: StillSpacing.md) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 20))
                        .foregroundStyle(StillColor.accent)

                    Text("this bench has seen me through so many ups and downs.")
                        .font(StillFont.body(17))
                        .foregroundStyle(StillColor.ink)
                        .lineSpacing(6)

                    Text("april 3, 2023")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                            Text("dolores park")
                        }
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)

                        Spacer()

                        Button {
                            isSaved.toggle()
                        } label: {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .foregroundStyle(StillColor.accent)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(StillSpacing.md)
        .background(StillColor.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(StillColor.ink)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("nearby memory")
                        .font(StillFont.heading(14))
                        .foregroundStyle(StillColor.ink)
                    Text("124m away")
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(StillColor.ink)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack { NearbyMemoryView() }
}
