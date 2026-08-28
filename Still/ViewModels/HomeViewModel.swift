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
    var memories: [Memory] = []
    var notifications: [StillNotification] = HomeViewModel.mockNotifications
    var isLoading = false
    var loadErrorMessage: String?

    /// Chosen once per refresh, not recomputed on every redraw —
    /// a computed property here would re-roll the random pick on
    /// every SwiftUI diff pass and flicker between sentences.
    var reflectionLine: String = ""

    private var repository: MemoryRepository?

    /// Called once from the view, where the environment (and so the
    /// model container) is actually available — can't be done in
    /// `init` since SwiftUI environment isn't ready yet at that point.
    func configure(repository: MemoryRepository) {
        self.repository = repository
    }

    func refresh() async {
        guard let repository else { return }
        isLoading = true
        loadErrorMessage = nil
        do {
            memories = try await repository.fetchAll()
        } catch {
            loadErrorMessage = "couldn't load your memories."
        }
        isLoading = false
        reflectionLine = Self.pickReflectionLine(
            memoriesThisWeek: memoriesThisWeekCount,
            placesThisWeek: placesThisWeekCount,
            revisitedThisWeek: revisitedThisWeekCount
        )
    }

    /// A memory actually dated today — not just "the most recent
    /// one," which could be from days ago if nothing's been written
    /// since.
    var todayMemory: Memory? {
        memories.first { Calendar.current.isDateInToday($0.date) }
    }

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

    // MARK: - Reflection

    /// A single sentence, not a stat — generated from the same data
    /// as "this week," no new state or analytics. Several templates
    /// per situation so it doesn't repeat the same line every time;
    /// deliberately plain rather than poetic — this should read like
    /// a quiet observation, not a caption trying to sound profound.
    private static func pickReflectionLine(memoriesThisWeek: Int, placesThisWeek: Int, revisitedThisWeek: Int) -> String {
        if memoriesThisWeek == 0 {
            return noMemoriesTemplates.randomElement() ?? noMemoriesTemplates[0]
        }
        if revisitedThisWeek > 0 {
            let templates = revisitedThisWeek == 1
                ? revisitedSingularTemplates
                : revisitedPluralTemplates(count: revisitedThisWeek)
            return templates.randomElement() ?? templates[0]
        }
        if placesThisWeek == 1 {
            return onePlaceTemplates.randomElement() ?? onePlaceTemplates[0]
        }
        let templates = multiplePlacesTemplates(count: placesThisWeek)
        return templates.randomElement() ?? templates[0]
    }

    private static let noMemoriesTemplates = [
        "nothing was written down this week.",
        "this week is still empty, and that's fine.",
        "no new memories yet this week.",
        "a quiet week so far.",
    ]

    private static let onePlaceTemplates = [
        "one place mattered enough to write down this week.",
        "this week stayed close to one place.",
        "one place made it into your week.",
        "just one place this week.",
    ]

    private static func multiplePlacesTemplates(count: Int) -> [String] {
        [
            "\(count) places found their way into this week.",
            "this week touched \(count) places.",
            "\(count) places, each written down.",
            "this week moved across \(count) places.",
        ]
    }

    private static let revisitedSingularTemplates = [
        "one place was worth returning to this week.",
        "somewhere familiar came up again this week.",
        "you went back to one place this week.",
    ]

    private static func revisitedPluralTemplates(count: Int) -> [String] {
        [
            "\(count) places were worth returning to this week.",
            "a few places came up more than once this week.",
            "you returned to \(count) places this week.",
        ]
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
    // Still fully mock — no notification backend exists yet.

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
