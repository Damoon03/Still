import Foundation

enum AuthState: Equatable {
    case signedOut
    case awaitingMagicLink(email: String)
    case signedIn(UserProfile)
}

enum AuthServiceError: Error {
    /// Thrown by an implementation that doesn't support a given
    /// method — e.g. `MockAuthService.handleAuthCallback`, since the
    /// mock has no real deep link to handle; or
    /// `SupabaseAuthService.verifyMagicLink`, since real magic links
    /// are completed via `handleAuthCallback` instead.
    case unsupported
}

/// The single boundary between the app and however sign-in actually
/// happens. `MockAuthService` is a local stand-in; `SupabaseAuthService`
/// is the real one. Same pattern as `MemoryRepository`.
protocol AuthService: Sendable {
    /// `identityToken` is Apple's signed JWT from the native sign-in
    /// flow — required for a real implementation to verify the user
    /// server-side. `userIdentifier` is Apple's stable per-app user
    /// id, useful even without server verification (what the mock
    /// uses).
    func signInWithApple(userIdentifier: String, identityToken: String, fullName: String?, email: String?) async throws -> UserProfile

    func requestMagicLink(email: String) async throws

    /// Dev-only completion path with no real link to tap — see
    /// `MockAuthService`. A real implementation should throw
    /// `.unsupported`; use `handleAuthCallback(url:)` instead.
    func verifyMagicLink(email: String) async throws -> UserProfile

    /// Completes a redirect-based sign-in (magic link today, other
    /// providers later) from the URL the OS handed the app.
    func handleAuthCallback(url: URL) async throws -> UserProfile

    func signOut() async throws

    /// Checks for an existing session on launch — nil if there isn't one.
    func restoreSession() async -> UserProfile?
}
