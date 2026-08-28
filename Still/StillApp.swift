import SwiftUI
import SwiftData
import Supabase

@main
struct StillApp: App {
    private let modelContainer: ModelContainer
    private let memoryRepository: MemoryRepository
    private let authService: AuthService

    init() {
        do {
            modelContainer = try ModelContainer(for: Memory.self)
        } catch {
            fatalError("Couldn't create the SwiftData store: \(error)")
        }

        // --- Backend selection ---
        // Now that a Supabase project exists, these two lines point
        // at the real implementations. If this doesn't compile yet
        // (package not added in Xcode, or a small SDK signature
        // mismatch), fall back to a known-working local build with:
        //   authService = MockAuthService()
        //   memoryRepository = LocalMemoryRepository(modelContainer: modelContainer)
        authService = SupabaseAuthService(client: SupabaseConfig.client)
        memoryRepository = SupabaseMemoryRepository(client: SupabaseConfig.client)
    }

    var body: some Scene {
        WindowGroup {
            AuthCoordinator(authService: authService)
                .environment(\.memoryRepository, memoryRepository)
        }
        .modelContainer(modelContainer)
    }
}
