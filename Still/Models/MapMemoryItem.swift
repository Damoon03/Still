//
//  MapMemoryItem.swift
//  Still
//
//  Wraps a Memory with the map-only metadata it doesn't carry itself
//  (origin, author). Once real friend/discovery data exists, `mockData`
//  can be deleted in favor of a repository call.
//

import Foundation
import CoreLocation

struct MapMemoryItem: Identifiable {
    let id: UUID
    let memory: Memory
    let origin: MemoryOrigin
    let authorName: String?

    var place: String { memory.place }
    var coordinate: CLLocationCoordinate2D? { memory.coordinate }
    var date: Date { memory.date }
    var previewText: String? { memory.text.isEmpty ? nil : memory.text }

    /// 1.0 = most recent, fading toward a floor as memories age.
    /// Only meaningful for `.own` memories — friend/discovery markers
    /// use a flat muted color regardless of age.
    var recencyOpacity: Double {
        let days = Date().timeIntervalSince(date) / 86_400
        switch days {
        case ..<7: return 1.0
        case ..<30: return 0.8
        case ..<90: return 0.6
        case ..<365: return 0.45
        default: return 0.3
        }
    }
}

extension MapMemoryItem {
    /// Mock friend/discovery pins only. "Own" pins now come from the
    /// real repository (see MapView). This still leans on
    /// `Memory.dummyData` purely as convenient placeholder content —
    /// these aren't meant to look like the user's real memories.
    static var mockSocialData: [MapMemoryItem] {
        let source = Memory.dummyData
        guard source.count > 2 else { return [] }

        return [
            MapMemoryItem(id: UUID(), memory: source[1], origin: .friend, authorName: "Emma"),
            MapMemoryItem(id: UUID(), memory: source[2], origin: .discovery, authorName: "A stranger")
        ]
    }
}
