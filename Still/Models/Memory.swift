import Foundation
import CoreLocation
import SwiftData

@Model
final class Memory: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var place: String
    var region: String
    var text: String
    var date: Date
    var icon: String
    var isPrivate: Bool
    var latitude: Double?
    var longitude: Double?

    init(
        id: UUID = UUID(),
        title: String,
        place: String,
        region: String,
        text: String,
        date: Date = .now,
        icon: String = "mappin",
        isPrivate: Bool = true,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.place = place
        self.region = region
        self.text = text
        self.date = date
        self.icon = icon
        self.isPrivate = isPrivate
        self.latitude = latitude
        self.longitude = longitude
    }

    /// nil when the memory was saved without a location (permission
    /// denied, or capture failed) — those memories simply don't get
    /// a pin on the map rather than defaulting to (0, 0).
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// A short display label for list rows, derived from `date` so
    /// it's always correct — never hand-authored like it used to be
    /// for the old dummy data.
    var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "today · " + date.formatted(date: .omitted, time: .shortened).lowercased()
        } else if calendar.isDateInYesterday(date) {
            return "yesterday"
        } else if calendar.isDate(date, equalTo: .now, toGranularity: .year) {
            return date.formatted(.dateTime.month(.abbreviated).day()).lowercased()
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day().year()).lowercased()
        }
    }
}

extension Memory {
    /// Unsaved, in-memory only — never inserted into the persistent
    /// store. Used as: (a) seed content the very first time the app
    /// runs, and (b) the source for the still-dummy Friends/Discoveries
    /// mock on the map. A `var` (not `let`) so every read hands back
    /// fresh instances rather than sharing object identity.
    static var dummyData: [Memory] {
        [
            Memory(
                title: "morning walk",
                place: "dolores park",
                region: "san francisco, ca",
                text: "clear mind, fresh air, good start. started the day with intention, one block at a time.",
                date: .now,
                icon: "figure.walk",
                isPrivate: true,
                latitude: 37.7596,
                longitude: -122.4269
            ),
            Memory(
                title: "sunset thoughts",
                place: "dolores park",
                region: "san francisco, ca",
                text: "beautiful evening. watched the sunset and felt grateful for the little things.",
                date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
                icon: "sun.max",
                isPrivate: true,
                latitude: 37.7597,
                longitude: -122.4268
            ),
            Memory(
                title: "coffee & ideas",
                place: "four barrel coffee",
                region: "san francisco, ca",
                text: "notebook out, coffee in hand. this is where the best ideas start.",
                date: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now,
                icon: "cup.and.saucer",
                isPrivate: false,
                latitude: 37.7614,
                longitude: -122.4241
            ),
            Memory(
                title: "weekend hike",
                place: "twin peaks",
                region: "san francisco, ca",
                text: "the whole city laid out below. worth every step up.",
                date: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
                icon: "mountain.2",
                isPrivate: true,
                latitude: 37.7544,
                longitude: -122.4477
            ),
            Memory(
                title: "airport feelings",
                place: "sfo terminal 2",
                region: "san francisco, ca",
                text: "somewhere between goodbye and hello. always a strange kind of quiet here.",
                date: Calendar.current.date(byAdding: .day, value: -10, to: .now) ?? .now,
                icon: "airplane",
                isPrivate: true,
                latitude: 37.6213,
                longitude: -122.3790
            ),
            Memory(
                title: "quiet bench",
                place: "dolores park",
                region: "san francisco, ca",
                text: "this bench has seen me through so many ups and downs.",
                date: Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now,
                icon: "leaf",
                isPrivate: false,
                latitude: 37.7598,
                longitude: -122.4270
            )
        ]
    }
}
