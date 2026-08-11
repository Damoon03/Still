import SwiftUI

/// A custom, dark-themed confirmation popup — deliberately not the
/// system `.confirmationDialog`/`.alert`, which render with the
/// system's own colors and font and don't pick up Still's design
/// system (dark surface, amber/danger accents, monospaced type).
struct ConfirmationPopup: View {
    let icon: String
    let title: String
    let message: String
    let confirmTitle: String
    var isDestructive: Bool = true
    var isLoading: Bool = false
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private var accentColor: Color { isDestructive ? StillColor.danger : StillColor.accent }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { if !isLoading { onCancel() } }

            VStack(spacing: StillSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(accentColor)
                }

                VStack(spacing: StillSpacing.xs) {
                    Text(title)
                        .font(StillFont.heading(16))
                        .foregroundStyle(StillColor.ink)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(StillFont.caption(13))
                        .foregroundStyle(StillColor.inkSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: StillSpacing.sm) {
                    Button(action: onConfirm) {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(StillColor.background)
                            } else {
                                Text(confirmTitle)
                                    .font(StillFont.heading(15))
                                    .foregroundStyle(StillColor.background)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StillSpacing.sm + 6)
                    }
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
                    .disabled(isLoading)

                    Button(action: onCancel) {
                        Text("cancel")
                            .font(StillFont.body(14))
                            .foregroundStyle(StillColor.inkSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StillSpacing.sm + 2)
                    }
                    .disabled(isLoading)
                }
            }
            .padding(StillSpacing.lg)
            .frame(maxWidth: 300)
            .background(StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.lg, style: .continuous))
        }
    }
}
