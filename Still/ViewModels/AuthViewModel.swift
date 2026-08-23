import Foundation
import Observation

@Observable
final class AuthViewModel {
    var state: AuthState = .signedOut
    var errorMessage: String?
    var isProcessing = false

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func restoreSession() async {
        if let profile = await authService.restoreSession() {
            state = .signedIn(profile)
        }
    }

    func signInWithApple(userIdentifier: String, identityToken: String, fullName: String?, email: String?) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            let profile = try await authService.signInWithApple(
                userIdentifier: userIdentifier,
                identityToken: identityToken,
                fullName: fullName,
                email: email
            )
            state = .signedIn(profile)
        } catch {
            errorMessage = "couldn't sign in — try again."
        }
    }

    /// Completes sign-in from a deep link (magic link today). Safe
    /// to call for any URL — implementations that don't recognize it
    /// throw, and that's surfaced as a normal error rather than a crash.
    func handleAuthCallback(url: URL) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            let profile = try await authService.handleAuthCallback(url: url)
            state = .signedIn(profile)
        } catch {
            errorMessage = "couldn't complete sign-in — try again."
        }
    }

    func requestMagicLink(email: String) async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            try await authService.requestMagicLink(email: trimmed)
            state = .awaitingMagicLink(email: trimmed)
        } catch {
            errorMessage = "couldn't send that link — try again."
        }
    }

    func verifyMagicLink() async {
        guard case .awaitingMagicLink(let email) = state else { return }
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            let profile = try await authService.verifyMagicLink(email: email)
            state = .signedIn(profile)
        } catch {
            errorMessage = "couldn't verify — try again."
        }
    }

    func useAnotherEmail() {
        state = .signedOut
        errorMessage = nil
    }

    func recordAppleSignInFailure() {
        errorMessage = "sign in with apple failed — try again."
    }

    func signOut() async {
        do {
            try await authService.signOut()
            state = .signedOut
        } catch {
            errorMessage = "couldn't sign out — try again."
        }
    }
}
