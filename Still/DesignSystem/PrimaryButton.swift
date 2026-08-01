import SwiftUI

struct PrimaryButton: View {
    let title: String
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(StillFont.heading(15))
                    .foregroundStyle(StillColor.background)
                if let subtitle {
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.background.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, StillSpacing.sm + 6)
        }
        .background(StillColor.accent)
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
    }
}
