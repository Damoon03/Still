import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.memoryRepository) private var memoryRepository
    @State private var showingSignOutConfirmation = false
    @State private var memoryCount = 0
    @State private var placeCount = 0

    private var profile: UserProfile? {
        if case .signedIn(let profile) = authViewModel.state { return profile }
        return nil
    }

    private var displayName: String {
        if let name = profile?.displayName, !name.isEmpty { return name }
        if let email = profile?.email, let prefix = email.split(separator: "@").first {
            return String(prefix)
        }
        return "you"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: StillSpacing.lg) {
                Circle()
                    .fill(StillColor.surfaceElevated)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Image(systemName: "person")
                            .font(.system(size: 32))
                            .foregroundStyle(StillColor.inkSecondary)
                    )

                VStack(spacing: 2) {
                    Text(displayName)
                        .font(StillFont.heading(17))
                        .foregroundStyle(StillColor.ink)
                    if let email = profile?.email {
                        Text(email)
                            .font(StillFont.caption(12))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                }

                HStack(spacing: StillSpacing.lg) {
                    VStack(spacing: 2) {
                        Text("\(memoryCount)")
                            .font(StillFont.heading(16))
                            .foregroundStyle(StillColor.ink)
                        Text("memories")
                            .font(StillFont.caption(11))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                    VStack(spacing: 2) {
                        Text("\(placeCount)")
                            .font(StillFont.heading(16))
                            .foregroundStyle(StillColor.ink)
                        Text("places")
                            .font(StillFont.caption(11))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                }

                Spacer()
            }
            .padding(.top, StillSpacing.xl)
            .padding(StillSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(StillColor.background)
            .onAppear {
                Task { await loadCounts() }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: FriendsView()) {
                        Image(systemName: "person.2")
                            .foregroundStyle(StillColor.ink)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showingSignOutConfirmation = true
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(StillColor.ink)
                    }
                }
            }
            .overlay {
                if showingSignOutConfirmation {
                    ConfirmationPopup(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "sign out?",
                        message: "you can sign back in anytime.",
                        confirmTitle: "sign out",
                        isDestructive: false,
                        onConfirm: {
                            Task { await authViewModel.signOut() }
                        },
                        onCancel: {
                            withAnimation(.easeOut(duration: 0.18)) {
                                showingSignOutConfirmation = false
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
        }
    }

    private func loadCounts() async {
        guard let memoryRepository else { return }
        do {
            let memories = try await memoryRepository.fetchAll()
            memoryCount = memories.count
            placeCount = Set(memories.map { $0.place }).count
        } catch {
            // Leave counts as-is rather than showing an error here —
            // this is a small secondary stat, not worth interrupting
            // the profile screen over.
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel(authService: MockAuthService()))
}
