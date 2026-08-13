import CoreLocation

/// One-shot location capture (not continuous tracking — Still only
/// ever needs "where am I right now, at the moment of writing").
final class CoreLocationService: NSObject, LocationService {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authContinuation: CheckedContinuation<Void, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentLocation() async throws -> CLLocation {
        try await ensureAuthorization()
        return try await withTimeout(seconds: 10) {
            try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                self.manager.requestLocation()
            }
        }
    }

    func placemark(for location: CLLocation) async throws -> (place: String, region: String) {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw LocationServiceError.unableToResolvePlacemark
        }

        let place = placemark.name ?? placemark.thoroughfare ?? "unknown place"
        let regionParts = [placemark.locality, placemark.administrativeArea].compactMap { $0 }
        let region = regionParts.isEmpty ? (placemark.country ?? "") : regionParts.joined(separator: ", ")

        return (place.lowercased(), region.lowercased())
    }

    private func ensureAuthorization() async throws {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .notDetermined:
            // Timed out here almost always means the system
            // permission alert never appeared (a known Simulator
            // quirk) rather than the person taking >30s to respond.
            try await withTimeout(seconds: 30) {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    self.authContinuation = continuation
                    self.manager.requestWhenInUseAuthorization()
                }
            }
        case .denied, .restricted:
            throw LocationServiceError.permissionDenied
        @unknown default:
            throw LocationServiceError.permissionDenied
        }
    }

    /// Races `operation` against a timer so a callback that never
    /// fires (CLLocationManager on the Simulator with no location
    /// set is notorious for this) fails gracefully instead of
    /// leaving the UI stuck in a loading state forever.
    private func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw LocationServiceError.timedOut
            }
            guard let result = try await group.next() else {
                throw LocationServiceError.timedOut
            }
            group.cancelAll()
            return result
        }
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authContinuation else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authContinuation = nil
            continuation.resume()
        case .denied, .restricted:
            authContinuation = nil
            continuation.resume(throwing: LocationServiceError.permissionDenied)
        case .notDetermined:
            break // still waiting on the user
        @unknown default:
            authContinuation = nil
            continuation.resume(throwing: LocationServiceError.permissionDenied)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
