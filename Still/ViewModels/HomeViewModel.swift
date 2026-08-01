//
//  HomeViewModel.swift
//  Still
//

import Foundation
import Observation

struct OnThisDayMemory {
    let memory: Memory
    let yearsAgo: Int
}

@Observable
final class HomeViewModel {
    var memories: [Memory] = Memory.dummyData
    var notifications: [StillNotification] = HomeViewModel.mockNotifications

    var todayMemory: Memory? { memories.first }

    /// A memory from the same month/day in a previous year, if one
    /// exists. Returns nil (rather than a placeholder) when nothing
    /// matches — the card should simply not appear that day.
    var onThisDay: OnThisDayMemory? {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let todayComponents = calendar.dateComponents([.month, .day], from: now)

        return memories
            .compactMap { memory -> OnThisDayMemory? in
                let comps = calendar.dateComponents([.month, .day, .year], from: memory.date)
                guard comps.month == todayComponents.month,
                      comps.day == todayComponents.day,
                      let year = comps.year,
                      year < currentYear else { return nil }
                return OnThisDayMemory(memory: memory, yearsAgo: currentYear - year)
            }
            .sorted { $0.yearsAgo < $1.yearsAgo }
            .first
    }

    // MARK: - This week

    private var memoriesThisWeek: [Memory] {
        let now = Date()
        let calendar = Calendar.current
        return memories.filter {
            guard let days = calendar.dateComponents([.day], from: $0.date, to: now).day else { return false }
            return days >= 0 && days < 7
        }
    }

    var placesThisWeekCount: Int {
        Set(memoriesThisWeek.map { $0.place }).count
    }

    var memoriesThisWeekCount: Int {
        memoriesThisWeek.count
    }

    /// Places visited more than once this week, as a simple stand-in
    /// for "revisited" until there's a real definition for it.
    var revisitedThisWeekCount: Int {
        Dictionary(grouping: memoriesThisWeek, by: { $0.place })
            .filter { $0.value.count > 1 }
            .count
    }

    // MARK: - Activity

    let weekdayLabels = ["m", "t", "w", "t", "f", "s", "s"]

    var activityValues: [CGFloat] {
        let calendar = Calendar.current
        var counts = [Int](repeating: 0, count: 7)
        for memory in memories {
            let weekday = calendar.component(.weekday, from: memory.date) // 1 = Sunday
            let index = (weekday + 5) % 7 // shift so Monday = 0
            counts[index] += 1
        }
        return counts.map { CGFloat($0) }
    }

    // MARK: - Mock notifications

    private static var mockNotifications: [StillNotification] {
        [
            StillNotification(
                id: UUID(),
                kind: .friendShare(from: "Emma"),
                date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                isRead: false
            ),
            StillNotification(
                id: UUID(),
                kind: .nearbyDiscovery(place: "Lands End"),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                isRead: false
            )
        ]
    }
}
