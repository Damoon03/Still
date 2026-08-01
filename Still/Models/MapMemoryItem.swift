//
//  MapMemoryItem.swift
//  Still
//
//  Wraps a Memory with the map-only metadata it doesn't carry itself
//  (origin, author). Now that Memory is confirmed to have `title`,
//  `text`, and `date`, this wrapper reads those directly instead of
//  duplicating them — so nothing consuming `.date` / `.previewText`
//  elsewhere needs to change.
//
//  Once real friend/discovery data exists, `mockData` can be deleted
//  in favor of a repository call.
//

import Foundation
import CoreLocation

struct MapMemoryItem: Identifiable {
    let id: UUID
    let memory: Memory
    let origin: MemoryOrigin
    let authorName: String?

    var place: String { memory.place }
    var coordinate: CLLocationCoordinate2D { memory.coordinate }
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
    /// Placeholder data so the map has something to render before
    /// this is wired to Supabase. Reuses your real dummy memories
    /// (relabeled with a different origin/author) rather than
    /// fabricating new `Memory` values, since the exact memberwise
    /// initializer order for Memory isn't visible from here.
    static var mockData: [MapMemoryItem] {
        let source = Memory.dummyData
        guard !source.isEmpty else { return [] }

        let own = source.map { memory in
            MapMemoryItem(id: memory.id, memory: memory, origin: .own, authorName: nil)
        }

        var extra: [MapMemoryItem] = []
        if source.count > 1 {
            extra.append(MapMemoryItem(id: UUID(), memory: source[1], origin: .friend, authorName: "Emma"))
        }
        if source.count > 2 {
            extra.append(MapMemoryItem(id: UUID(), memory: source[2], origin: .discovery, authorName: "A stranger"))
        }

        return own + extra
    }
}
