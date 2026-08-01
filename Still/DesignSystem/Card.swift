import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(StillSpacing.md)
            .background(StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.lg, style: .continuous))
    }
}
