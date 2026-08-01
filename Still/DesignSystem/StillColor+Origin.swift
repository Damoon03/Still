//
//  StillColor+Origin.swift
//  Still
//
//  New color tokens for the map's friend/discovery markers.
//  `StillColor.accent` is left untouched — it's already the warm
//  yellow used for the user's own memories, so recency is expressed
//  through opacity rather than a new color.
//

import SwiftUI

extension StillColor {
    /// Muted, calm blue for friends' shared memories — secondary to
    /// the user's own memories, never competing with them.
    static let friendMemory = Color(red: 0.53, green: 0.62, blue: 0.72)

    /// Muted lavender for discoveries — quietly mysterious, never loud.
    static let discoveryMemory = Color(red: 0.62, green: 0.56, blue: 0.74)
}
