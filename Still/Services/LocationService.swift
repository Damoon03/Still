import CoreLocation

enum LocationServiceError: Error {
    case permissionDenied
    case unableToDetermineLocation
    case unableToResolvePlacemark
    case timedOut
}

/// The boundary between views and CoreLocation. Kept as a protocol
/// so previews/tests can swap in a fake without touching real
/// location hardware — same reasoning as `MemoryRepository`.
protocol LocationService {
    func currentLocation() async throws -> CLLocation
    func placemark(for location: CLLocation) async throws -> (place: String, region: String)
}
