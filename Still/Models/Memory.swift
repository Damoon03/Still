import Foundation
import CoreLocation

struct Memory: Identifiable {
    let id = UUID()
    let title: String
    let place: String
    let region: String
    let dateLabel: String
    let date: Date
    let text: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
    let isPrivate: Bool
}

extension Memory {
    static let dummyData: [Memory] = [
        Memory(
            title: "morning walk",
            place: "dolores park",
            region: "san francisco, ca",
            dateLabel: "today · 7:45 am",
            date: .now,
            text: "clear mind, fresh air, good start. started the day with intention, one block at a time.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7596, longitude: -122.4269),
            icon: "figure.walk",
            isPrivate: true
        ),
        Memory(
            title: "sunset thoughts",
            place: "dolores park",
            region: "san francisco, ca",
            dateLabel: "yesterday",
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            text: "beautiful evening. watched the sunset and felt grateful for the little things.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7597, longitude: -122.4268),
            icon: "sun.max",
            isPrivate: true
        ),
        Memory(
            title: "coffee & ideas",
            place: "four barrel coffee",
            region: "san francisco, ca",
            dateLabel: "may 12",
            date: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now,
            text: "notebook out, coffee in hand. this is where the best ideas start.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7614, longitude: -122.4241),
            icon: "cup.and.saucer",
            isPrivate: false
        ),
        Memory(
            title: "weekend hike",
            place: "twin peaks",
            region: "san francisco, ca",
            dateLabel: "may 10",
            date: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
            text: "the whole city laid out below. worth every step up.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7544, longitude: -122.4477),
            icon: "mountain.2",
            isPrivate: true
        ),
        Memory(
            title: "airport feelings",
            place: "sfo terminal 2",
            region: "san francisco, ca",
            dateLabel: "may 8",
            date: Calendar.current.date(byAdding: .day, value: -10, to: .now) ?? .now,
            text: "somewhere between goodbye and hello. always a strange kind of quiet here.",
            coordinate: CLLocationCoordinate2D(latitude: 37.6213, longitude: -122.3790),
            icon: "airplane",
            isPrivate: true
        ),
        Memory(
            title: "quiet bench",
            place: "dolores park",
            region: "san francisco, ca",
            dateLabel: "apr 3, 2023",
            date: Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now,
            text: "this bench has seen me through so many ups and downs.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7598, longitude: -122.4270),
            icon: "leaf",
            isPrivate: false
        )
    ]
}
