import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let memoryCount: Int
}

extension Friend {
    static let dummyData: [Friend] = [
        Friend(name: "alex", memoryCount: 12),
        Friend(name: "maya", memoryCount: 8),
        Friend(name: "jordan", memoryCount: 5),
        Friend(name: "sarah", memoryCount: 3),
        Friend(name: "sam", memoryCount: 2)
    ]
}
