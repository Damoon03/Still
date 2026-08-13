import Foundation
import Supabase

/// Real Supabase-backed implementation of `MemoryRepository`.
/// Conforms to the same protocol as `LocalMemoryRepository` — nothing
/// in HomeViewModel, MapView, MemoryDetailView, or NewMemoryView
/// needs to change to use this instead. Row Level Security (see
/// supabase/schema.sql) does the "only your own memories" scoping —
/// this layer doesn't need to filter by user itself for reads.
///
/// NOTE: written against Supabase's documented Swift/PostgREST API
/// but not compiled — some method/type names may need small
/// adjustments the first time this builds in Xcode.
final class SupabaseMemoryRepository: MemoryRepository, @unchecked Sendable {
    private let client: SupabaseClient
    private let table = "memories"

    init(client: SupabaseClient) {
        self.client = client
    }

    /// Wire row shape — matches supabase/schema.sql exactly.
    /// `Memory` itself (the SwiftData @Model) stays the shared
    /// currency between repositories; this is purely a transport
    /// detail of talking to Postgres.
    private struct MemoryRow: Codable {
        var id: UUID
        var user_id: UUID
        var title: String
        var place: String
        var region: String
        var text: String
        var date: Date
        var icon: String
        var is_private: Bool
        var latitude: Double?
        var longitude: Double?
    }

    private struct MemoryUpdate: Codable {
        var title: String
        var text: String
        var is_private: Bool
    }

    func fetchAll() async throws -> [Memory] {
        let rows: [MemoryRow] = try await client
            .from(table)
            .select()
            .order("date", ascending: false)
            .execute()
            .value

        return rows.map(makeMemory)
    }

    func create(_ memory: Memory) async throws {
        let session = try await client.auth.session
        let row = MemoryRow(
            id: memory.id,
            user_id: session.user.id,
            title: memory.title,
            place: memory.place,
            region: memory.region,
            text: memory.text,
            date: memory.date,
            icon: memory.icon,
            is_private: memory.isPrivate,
            latitude: memory.latitude,
            longitude: memory.longitude
        )
        try await client.from(table).insert(row).execute()
    }

    func delete(id: UUID) async throws {
        try await client.from(table).delete().eq("id", value: id).execute()
    }

    func update(id: UUID, apply: @escaping @Sendable (Memory) -> Void) async throws {
        let rows: [MemoryRow] = try await client
            .from(table)
            .select()
            .eq("id", value: id)
            .execute()
            .value

        guard let row = rows.first else { throw MemoryRepositoryError.notFound }

        let memory = makeMemory(from: row)
        apply(memory)

        let update = MemoryUpdate(title: memory.title, text: memory.text, is_private: memory.isPrivate)
        try await client.from(table).update(update).eq("id", value: id).execute()
    }

    private func makeMemory(from row: MemoryRow) -> Memory {
        Memory(
            id: row.id,
            title: row.title,
            place: row.place,
            region: row.region,
            text: row.text,
            date: row.date,
            icon: row.icon,
            isPrivate: row.is_private,
            latitude: row.latitude,
            longitude: row.longitude
        )
    }
}
