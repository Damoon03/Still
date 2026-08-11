import SwiftUI

private struct MemoryRepositoryKey: EnvironmentKey {
    static let defaultValue: MemoryRepository? = nil
}

extension EnvironmentValues {
    /// The one shared repository instance for the app's lifetime.
    /// Deliberately not "construct one whenever you need it" — a
    /// `LocalMemoryRepository` is a SwiftData `@ModelActor`, and any
    /// `Memory` objects it fetches become unusable the moment that
    /// specific actor instance deallocates. A single long-lived
    /// instance, set once in `StillApp` and read here, avoids that
    /// entirely.
    var memoryRepository: MemoryRepository? {
        get { self[MemoryRepositoryKey.self] }
        set { self[MemoryRepositoryKey.self] = newValue }
    }
}
