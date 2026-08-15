import Foundation

/// Local-only stand-in for real sign-in. Persists a session to
/// UserDefaults purely so "stay signed in across relaunch" is
/// demonstrable. Kept in the codebase even after SupabaseAuthService
/// exists — it's the easy fallback if the real one doesn't compile
/// or a Supabase call fails during development (see StillApp.swift).
actor MockAuthService: AuthService {
    private let sessionKey = "still.mock.session"

    func signInWithApple(userIdentifier: String, identityToken: String, fullName: String?, email: String?) async throws -> UserProfile {
        // identityToken is ignored — nothing to verify locally.
        let profile = UserProfile(id: userIdentifier, displayName: fullName, email: email)
        try persist(profile)
        return profile
    }

    func requestMagicLink(email: String) async throws {
        // No real email goes out — the brief delay just makes the
        // mock feel like something actually happened rather than instant.
        try await Task.sleep(nanoseconds: 400_000_000)
    }

    func verifyMagicLink(email: String) async throws -> UserProfile {
        let profile = UserProfile(id: email, displayName: nil, email: email)
        try persist(profile)
        return profile
    }

    func handleAuthCallback(url: URL) async throws -> UserProfile {
        // The mock has no real deep link to complete — SignInView's
        // "(dev) I clicked the link" button calls verifyMagicLink
        // directly instead of going through a URL.
        throw AuthServiceError.unsupported
    }

    func signOut() async throws {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    func restoreSession() async -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func persist(_ profile: UserProfile) throws {
        let data = try JSONEncoder().encode(profile)
        UserDefaults.standard.set(data, forKey: sessionKey)
    }
}
