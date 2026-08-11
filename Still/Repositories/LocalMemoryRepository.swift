import Foundation
import SwiftData

/// Local, on-device storage via SwiftData. No auth, no network — this
/// is purely "does the note survive a relaunch." Meant to be swapped
/// for a Supabase-backed repository later without any caller changes.
@ModelActor
actor LocalMemoryRepository: MemoryRepository {
    func fetchAll() async throws -> [Memory] {
        let descriptor = FetchDescriptor<Memory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func create(_ memory: Memory) async throws {
        modelContext.insert(memory)
        try modelContext.save()
    }

    func delete(id: UUID) async throws {
        let targetID = id
        let descriptor = FetchDescriptor<Memory>(
            predicate: #Predicate<Memory> { $0.id == targetID }
        )
        guard let memory = try modelContext.fetch(descriptor).first else {
            throw MemoryRepositoryError.notFound
        }
        modelContext.delete(memory)
        try modelContext.save()
    }

    func update(id: UUID, apply: @escaping @Sendable (Memory) -> Void) async throws {
        let targetID = id
        let descriptor = FetchDescriptor<Memory>(
            predicate: #Predicate<Memory> { $0.id == targetID }
        )
        guard let memory = try modelContext.fetch(descriptor).first else {
            throw MemoryRepositoryError.notFound
        }
        apply(memory)
        try modelContext.save()
    }
}
