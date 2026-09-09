import SwiftUI

struct MemoryRow: View {
    let memory: Memory

    var body: some View {
        HStack(spacing: StillSpacing.sm + 4) {
            IconAvatar(systemName: memory.icon)

            VStack(alignment: .leading, spacing: 2) {
                Text(memory.title)
                    .font(StillFont.heading(14))
                    .foregroundStyle(StillColor.ink)
                Text("\(memory.dateLabel) · \(memory.place)")
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)
            }

            Spacer()

            Image(systemName: "bookmark")
                .font(.system(size: 14))
                .foregroundStyle(StillColor.inkSecondary)
        }
        .padding(StillSpacing.md)
        .background(StillColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
    }
}
