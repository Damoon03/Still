import Foundation
import Supabase

/// Real Supabase-backed implementation of `AuthService`. Conforms to
/// the same protocol as `MockAuthService` — nothing in AuthViewModel,
/// SignInView, or AuthCoordinator needs to change to use this instead.
///
/// NOTE: written against Supabase's documented Swift API but not
/// compiled — some method/type names may need small adjustments the
/// first time this builds in Xcode.
final class SupabaseAuthService: AuthService, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func signInWithApple(userIdentifier: String, identityToken: String, fullName: String?, email: String?) async throws -> UserProfile {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: identityToken)
        )

        // Apple only sends the name once, on the very first sign-in.
        // Persist it to the Supabase user record so a later sign-in
        // (or restoreSession) doesn't lose it.
        if let fullName, !fullName.isEmpty {
            _ = try? await client.auth.update(user: UserAttributes(data: ["full_name": .string(fullName)]))
        }

        return profile(from: session.user, fallbackName: fullName, fallbackEmail: email)
    }

    func requestMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(email: email, redirectTo: SupabaseConfig.magicLinkRedirectURL)
    }

    func verifyMagicLink(email: String) async throws -> UserProfile {
        // Real magic links complete via handleAuthCallback(url:) when
        // the OS opens the redirect URL — there's no token to verify
        // from just an email address. This exists only so the
        // protocol has one shape for both implementations.
        throw AuthServiceError.unsupported
    }

    func handleAuthCallback(url: URL) async throws -> UserProfile {
        let session = try await client.auth.session(from: url)
        return profile(from: session.user, fallbackName: nil, fallbackEmail: nil)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func restoreSession() async -> UserProfile? {
        do {
            let session = try await client.auth.session
            return profile(from: session.user, fallbackName: nil, fallbackEmail: nil)
        } catch {
            return nil
        }
    }

    private func profile(from user: User, fallbackName: String?, fallbackEmail: String?) -> UserProfile {
        let name = stringValue(in: user.userMetadata, key: "full_name") ?? fallbackName
        return UserProfile(
            id: user.id.uuidString,
            displayName: name,
            email: user.email ?? fallbackEmail
        )
    }

    private func stringValue(in metadata: [String: AnyJSON]?, key: String) -> String? {
        guard case .string(let value)? = metadata?[key] else { return nil }
        return value
    }
}
