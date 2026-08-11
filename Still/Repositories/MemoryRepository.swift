import Foundation

enum MemoryRepositoryError: Error {
    /// Thrown by delete/update when no record with that id exists —
    /// notably, this happens if you pass in one of the unsaved
    /// `Memory.dummyData` instances, since those were never inserted
    /// anywhere. Expected and handled gracefully, not a crash case.
    case notFound
}

/// The single boundary between views/view models and however memories
/// are actually stored. Today there's one implementation
/// (`LocalMemoryRepository`, backed by SwiftData). Later, a
/// `SupabaseMemoryRepository` can conform to this same protocol and
/// nothing above this layer has to change — same pattern as
/// `AuthService` for auth.
protocol MemoryRepository: Sendable {
    /// All persisted memories, newest first.
    func fetchAll() async throws -> [Memory]

    /// Persists a new memory.
    func create(_ memory: Memory) async throws

    /// Fetches the memory with this id fresh (within this
    /// repository's own context) and deletes it. Deliberately takes
    /// an id rather than a `Memory` instance — SwiftData model
    /// objects are tied to the context that fetched them, and a
    /// caller may be holding one fetched by a *different*
    /// repository instance.
    func delete(id: UUID) async throws

    /// Fetches the memory with this id fresh, applies `apply` to it,
    /// then saves. Same reasoning as `delete(id:)` — this guarantees
    /// the fetch and the save happen through the same context.
    func update(id: UUID, apply: @escaping @Sendable (Memory) -> Void) async throws
}
