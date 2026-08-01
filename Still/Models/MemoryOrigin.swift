//
//  MemoryOrigin.swift
//  Still
//
//  Distinguishes where a memory on the map came from.
//  NOTE: This does not yet exist on your real `Memory` model.
//  Add a `let origin: MemoryOrigin` (default `.own`) to Memory once
//  you're ready to wire this to Supabase. Until then, MapMemoryItem
//  below carries this alongside a plain Memory so nothing in your
//  existing model needs to change yet.
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
