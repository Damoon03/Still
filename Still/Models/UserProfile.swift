import Foundation

struct UserProfile: Identifiable, Codable, Sendable, Equatable {
    var id: String
    var displayName: String?
    var email: String?
}
