import SwiftUI

struct IconAvatar: View {
    let systemName: String
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(StillColor.accentDim)
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .regular))
                .foregroundStyle(StillColor.accent)
        }
        .frame(width: size, height: size)
    }
}
