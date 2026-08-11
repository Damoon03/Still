import SwiftUI

struct PrimaryButton: View {
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled

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
        .background(StillColor.accent.opacity(isEnabled ? 1 : 0.4))
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
    }
}
