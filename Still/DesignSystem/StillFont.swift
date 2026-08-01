import SwiftUI

enum StillFont {
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }

    static func heading(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}
