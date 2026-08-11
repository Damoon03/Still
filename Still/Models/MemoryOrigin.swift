//
//  MemoryOrigin.swift
//  Still
//
//  Distinguishes where a memory on the map came from.
//

import SwiftUI

enum MemoryOrigin: String, CaseIterable, Identifiable {
    case own
    case friend
    case discovery

    var id: String { rawValue }

    var label: String {
        switch self {
        case .own: return "My Memories"
        case .friend: return "Friends"
        case .discovery: return "Discoveries"
        }
    }
}
