import SwiftUI
import AuthenticationServices

struct SignInView: View {
    var viewModel: AuthViewModel
    @State private var email = ""

    var body: some View {
        VStack(spacing: StillSpacing.xl) {
            Spacer()

            VStack(spacing: StillSpacing.sm) {
                Circle()
                    .fill(StillColor.accent)
                    .frame(width: 10, height: 10)
                Text("still")
                    .font(StillFont.title(30))
                    .foregroundStyle(StillColor.ink)
                Text("a quiet place for what mattered, where it mattered.")
                    .font(StillFont.caption(13))
                    .foregroundStyle(StillColor.inkSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            if case .awaitingMagicLink(let pendingEmail) = viewModel.state {
                awaitingMagicLinkSection(pendingEmail)
            } else {
                signInOptions
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.danger)
            }

            Spacer()
        }
        .padding(StillSpacing.lg)
        .background(StillColor.background.ignoresSafeArea())
    }

    private var signInOptions: some View {
        VStack(spacing: StillSpacing.md) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
            .disabled(viewModel.isProcessing)

            HStack(spacing: StillSpacing.sm) {
                Rectangle().fill(StillColor.divider).frame(height: 1)
                Text("or")
                    .font(StillFont.caption(11))
                    .foregroundStyle(StillColor.inkSecondary)
                Rectangle().fill(StillColor.divider).frame(height: 1)
            }

            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                TextField("email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .font(StillFont.body(15))
                    .foregroundStyle(StillColor.ink)
                    .padding(StillSpacing.md)
                    .background(StillColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))

                PrimaryButton(title: viewModel.isProcessing ? "sending…" : "send magic link") {
                    Task { await viewModel.requestMagicLink(email: email) }
                }
                .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isProcessing)
            }
        }
    }

    private func awaitingMagicLinkSection(_ email: String) -> some View {
        VStack(spacing: StillSpacing.md) {
            Image(systemName: "envelope")
                .font(.system(size: 28))
                .foregroundStyle(StillColor.accent)

            VStack(spacing: 4) {
                Text("check your email")
                    .font(StillFont.heading(16))
                    .foregroundStyle(StillColor.ink)
                Text("we sent a link to \(email).")
                    .font(StillFont.caption(13))
                    .foregroundStyle(StillColor.inkSecondary)
                    .multilineTextAlignment(.center)
            }

            // Dev-only stand-in: there's no real email or deep link
            // yet, so this takes the place of tapping the link that
            // would normally arrive. Remove once Supabase magic-link
            // deep linking is wired up.
            PrimaryButton(title: viewModel.isProcessing ? "verifying…" : "(dev) I clicked the link") {
                Task { await viewModel.verifyMagicLink() }
            }
            .disabled(viewModel.isProcessing)

            Button("use a different email") {
                viewModel.useAnotherEmail()
            }
            .font(StillFont.caption(12))
            .foregroundStyle(StillColor.inkSecondary)
            .disabled(viewModel.isProcessing)
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else {
                viewModel.recordAppleSignInFailure()
                return
            }
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            Task {
                await viewModel.signInWithApple(
                    userIdentifier: credential.user,
                    identityToken: identityToken,
                    fullName: fullName.isEmpty ? nil : fullName,
                    email: credential.email
                )
            }
        case .failure:
            viewModel.recordAppleSignInFailure()
        }
    }
}

#Preview {
    SignInView(viewModel: AuthViewModel(authService: MockAuthService()))
}
