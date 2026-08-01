import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StillSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(memory.place)
                            .font(StillFont.heading(15))
                    }
                    .foregroundStyle(StillColor.ink)

                    Text(memory.region)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)
                }

                Text(memory.text)
                    .font(StillFont.body(17))
                    .foregroundStyle(StillColor.ink)
                    .lineSpacing(6)

                Text(memory.date.formatted(date: .abbreviated, time: .shortened).lowercased())
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)

                Divider().background(StillColor.divider)

                VStack(spacing: 0) {
                    detailRow(
                        icon: memory.isPrivate ? "lock" : "eye",
                        title: memory.isPrivate ? "private" : "discoverable",
                        subtitle: memory.isPrivate ? "only you" : "shared with others"
                    )
                    detailRow(icon: "pencil", title: "edit memory", subtitle: nil)
                    detailRow(icon: "trash", title: "delete memory", subtitle: nil, tint: StillColor.danger)
                }
            }
            .padding(StillSpacing.lg)
        }
        .background(StillColor.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(StillColor.ink)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(StillColor.ink)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func detailRow(icon: String, title: String, subtitle: String?, tint: Color = StillColor.ink) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint == StillColor.danger ? StillColor.danger : StillColor.inkSecondary)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(StillFont.body(14))
                        .foregroundStyle(tint)
                    if let subtitle {
                        Text(subtitle)
                            .font(StillFont.caption(11))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, StillSpacing.sm + 2)

            Divider().background(StillColor.divider)
        }
    }
}

#Preview {
    NavigationStack {
        MemoryDetailView(memory: Memory.dummyData[0])
    }
}
