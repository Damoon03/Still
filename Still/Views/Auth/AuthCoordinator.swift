import SwiftUI

struct AuthCoordinator: View {
    @State private var viewModel: AuthViewModel
    @State private var hasCheckedSession = false

    init(authService: AuthService) {
        _viewModel = State(initialValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .signedOut, .awaitingMagicLink:
                SignInView(viewModel: viewModel)
            case .signedIn:
                RootView()
                    .environment(viewModel)
            }
        }
        .task {
            guard !hasCheckedSession else { return }
            hasCheckedSession = true
            await viewModel.restoreSession()
        }
        .onOpenURL { url in
            Task { await viewModel.handleAuthCallback(url: url) }
        }
    }
}

#Preview {
    AuthCoordinator(authService: MockAuthService())
}
