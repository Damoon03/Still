import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.memoryRepository) private var memoryRepository

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var actionErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StillSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(memory.place)
                            .font(StillFont.heading(15))
                    }
                    .foregroundStyle(StillColor.ink)

                    Text(memory.region)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)
                }

                Text(memory.text)
                    .font(StillFont.body(17))
                    .foregroundStyle(StillColor.ink)
                    .lineSpacing(6)

                Text(memory.date.formatted(date: .abbreviated, time: .shortened).lowercased())
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)

                Divider().background(StillColor.divider)

                VStack(spacing: 0) {
                    detailRow(
                        icon: memory.isPrivate ? "lock" : "eye",
                        title: memory.isPrivate ? "private" : "discoverable",
                        subtitle: memory.isPrivate ? "only you" : "shared with others"
                    )
                    detailRow(icon: "pencil", title: "edit memory", subtitle: nil) {
                        showingEditSheet = true
                    }
                    detailRow(icon: "trash", title: "delete memory", subtitle: nil, tint: StillColor.danger) {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showingDeleteConfirmation = true
                        }
                    }
                }

                if let actionErrorMessage {
                    Text(actionErrorMessage)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.danger)
                }
            }
            .padding(StillSpacing.lg)
        }
        .background(StillColor.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(StillColor.ink)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(StillColor.ink)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingEditSheet) {
            NewMemoryView(editingMemory: memory, onSaved: {
                // Pop back to the list rather than showing a stale
                // copy of the text here — the list re-reads fresh
                // data on reappear (see HomeView/MapView onAppear).
                dismiss()
            })
        }
        .overlay {
            if showingDeleteConfirmation {
                ConfirmationPopup(
                    icon: "trash",
                    title: "delete this memory?",
                    message: "this can't be undone.",
                    confirmTitle: "delete",
                    isLoading: isDeleting,
                    onConfirm: {
                        Task { await deleteMemory() }
                    },
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showingDeleteConfirmation = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
    }

    private func deleteMemory() async {
        guard let memoryRepository else {
            actionErrorMessage = "couldn't delete this memory — try again."
            return
        }
        isDeleting = true
        actionErrorMessage = nil
        defer { isDeleting = false }

        do {
            try await memoryRepository.delete(id: memory.id)
            dismiss()
        } catch {
            withAnimation(.easeOut(duration: 0.18)) {
                showingDeleteConfirmation = false
            }
            actionErrorMessage = "couldn't delete this memory — it may not be saved yet."
        }
    }

    private func detailRow(
        icon: String,
        title: String,
        subtitle: String?,
        tint: Color = StillColor.ink,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 0) {
            Group {
                if let action {
                    Button(action: action) {
                        detailRowContent(icon: icon, title: title, subtitle: subtitle, tint: tint)
                    }
                    .buttonStyle(.plain)
                } else {
                    detailRowContent(icon: icon, title: title, subtitle: subtitle, tint: tint)
                }
            }
            .padding(.vertical, StillSpacing.sm + 2)

            Divider().background(StillColor.divider)
        }
    }

    private func detailRowContent(icon: String, title: String, subtitle: String?, tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(tint == StillColor.danger ? StillColor.danger : StillColor.inkSecondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(StillFont.body(14))
                    .foregroundStyle(tint)
                if let subtitle {
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        MemoryDetailView(memory: Memory.dummyData[0])
    }
}
