import SwiftUI
import CoreLocation

struct NewMemoryView: View {
    /// nil = creating a new memory. Non-nil = editing an existing
    /// one. This instance is used only to pre-fill the form — saving
    /// re-fetches by id inside the repository rather than mutating
    /// this object directly, since it may belong to a different
    /// SwiftData context than the one doing the save.
    private let editingMemory: Memory?
    private let onSaved: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.memoryRepository) private var memoryRepository

    @State private var text: String
    @State private var isDiscoverable: Bool
    @State private var shareWithFriends = false
    @State private var shareWithFutureVisitors = false

    @State private var locationService: LocationService = CoreLocationService()
    @State private var isLoadingLocation: Bool
    @State private var capturedCoordinate: CLLocationCoordinate2D?
    @State private var capturedPlace: String
    @State private var capturedRegion: String
    @State private var locationErrorMessage: String?

    @State private var isSaving = false
    @State private var saveErrorMessage: String?

    private let characterLimit = 300

    init(editingMemory: Memory? = nil, onSaved: (() -> Void)? = nil) {
        self.editingMemory = editingMemory
        self.onSaved = onSaved

        _text = State(initialValue: editingMemory?.text ?? "")
        _isDiscoverable = State(initialValue: editingMemory.map { !$0.isPrivate } ?? false)
        _capturedPlace = State(initialValue: editingMemory?.place ?? "")
        _capturedRegion = State(initialValue: editingMemory?.region ?? "")
        _capturedCoordinate = State(initialValue: editingMemory?.coordinate)
        // Editing never re-captures location — the place stays what
        // it was when the memory was written.
        _isLoadingLocation = State(initialValue: editingMemory == nil)
    }

    private var isEditing: Bool { editingMemory != nil }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StillSpacing.lg) {
                    placeRow
                    textEditorArea
                    discoverabilitySection

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .font(StillFont.caption(12))
                            .foregroundStyle(StillColor.danger)
                    }
                }
                .padding(StillSpacing.md)
            }
            .background(StillColor.background)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: isSaving ? "saving…" : (isEditing ? "save changes" : "leave here"),
                    subtitle: isEditing ? nil : "make this place part of your story"
                ) {
                    Task { await saveMemory() }
                }
                .disabled(!canSave)
                .padding(StillSpacing.md)
                .background(StillColor.background)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(StillColor.ink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(isEditing ? "edit memory" : "new memory")
                        .font(StillFont.heading(15))
                        .foregroundStyle(StillColor.ink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") { Task { await saveMemory() } }
                        .font(StillFont.body(14))
                        .foregroundStyle(canSave ? StillColor.accent : StillColor.inkSecondary)
                        .disabled(!canSave)
                }
            }
            .task {
                if !isEditing {
                    await captureLocation()
                }
            }
        }
    }

    // MARK: - Location

    private func captureLocation() async {
        isLoadingLocation = true
        locationErrorMessage = nil
        do {
            let location = try await locationService.currentLocation()
            let resolved = try await locationService.placemark(for: location)
            capturedCoordinate = location.coordinate
            capturedPlace = resolved.place
            capturedRegion = resolved.region
        } catch {
            // No fake location, no fake pin — the memory just saves
            // without one. Place becomes editable so it isn't left
            // blank.
            locationErrorMessage = "couldn't find your location — type where you are instead."
        }
        isLoadingLocation = false
    }

    // MARK: - Save

    private func saveMemory() async {
        guard canSave else { return }
        guard let memoryRepository else {
            saveErrorMessage = "couldn't save that — try again."
            return
        }
        isSaving = true
        saveErrorMessage = nil
        defer { isSaving = false }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlace = capturedPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTitle = deriveTitle(from: trimmedText)
        let newIsPrivate = !isDiscoverable

        do {
            if let editingMemory {
                try await memoryRepository.update(id: editingMemory.id) { memory in
                    memory.text = trimmedText
                    memory.title = newTitle
                    memory.isPrivate = newIsPrivate
                    // Place/region/coordinate/date are untouched —
                    // relocating a memory isn't supported yet, and a
                    // memory's date is when it happened, not when it
                    // was last edited.
                }
            } else {
                let memory = Memory(
                    title: newTitle,
                    place: trimmedPlace.isEmpty ? "unknown place" : trimmedPlace,
                    region: capturedRegion,
                    text: trimmedText,
                    date: .now,
                    icon: "mappin",
                    isPrivate: newIsPrivate,
                    latitude: capturedCoordinate?.latitude,
                    longitude: capturedCoordinate?.longitude
                )
                try await memoryRepository.create(memory)
            }

            onSaved?()
            dismiss()
        } catch {
            saveErrorMessage = "couldn't save that — try again."
        }
    }

    /// No title field in this screen by design — the first handful
    /// of words the person wrote stands in for one, same way a
    /// paper journal doesn't ask you to caption yourself.
    private func deriveTitle(from text: String) -> String {
        let words = text.split(separator: " ", omittingEmptySubsequences: true)
        guard !words.isEmpty else { return "untitled" }
        let titleWords = words.prefix(6)
        let title = titleWords.joined(separator: " ")
        return words.count > 6 ? title + "…" : title
    }

    // MARK: - Place row

    private var placeRow: some View {
        HStack(alignment: isLoadingLocation ? .center : .top) {
            IconAvatar(systemName: "mappin", size: 34)

            VStack(alignment: .leading, spacing: 4) {
                if isLoadingLocation {
                    Text("finding your place…")
                        .font(StillFont.heading(15))
                        .foregroundStyle(StillColor.inkSecondary)
                } else if let locationErrorMessage {
                    Text(locationErrorMessage)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)
                    TextField("where are you?", text: $capturedPlace)
                        .font(StillFont.heading(15))
                        .foregroundStyle(StillColor.ink)
                } else {
                    Text(capturedPlace.isEmpty ? "unknown place" : capturedPlace)
                        .font(StillFont.heading(15))
                        .foregroundStyle(StillColor.ink)
                    if !capturedRegion.isEmpty {
                        Text(capturedRegion)
                            .font(StillFont.caption(12))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                }
            }

            Spacer()

            if isLoadingLocation {
                ProgressView()
                    .tint(StillColor.accent)
            } else if locationErrorMessage == nil {
                Image(systemName: "gearshape")
                    .foregroundStyle(StillColor.inkSecondary)
            }
        }
    }

    private var textEditorArea: some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextEditor(text: $text)
                .font(StillFont.body(15))
                .foregroundStyle(StillColor.ink)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 160)
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("what happened here?")
                            .font(StillFont.body(15))
                            .foregroundStyle(StillColor.inkSecondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }

            Text("\(text.count) / \(characterLimit)")
                .font(StillFont.caption(11))
                .foregroundStyle(StillColor.inkSecondary)
        }
    }

    private var discoverabilitySection: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("who can discover this?")
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)

            optionRow(
                icon: "lock",
                title: "private",
                subtitle: "only you",
                isSelected: !isDiscoverable
            ) {
                isDiscoverable = false
            }

            optionRow(
                icon: "eye",
                title: "discoverable",
                subtitle: "share with others",
                isSelected: isDiscoverable
            ) {
                isDiscoverable = true
            }

            if isDiscoverable {
                VStack(alignment: .leading, spacing: StillSpacing.sm) {
                    Text("if discoverable, who?")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)

                    checkboxRow(icon: "person.2", title: "friends", subtitle: "your friends on still", isOn: $shareWithFriends)
                    checkboxRow(icon: "globe", title: "future visitors", subtitle: "people who visit this place", isOn: $shareWithFutureVisitors)
                }
                .padding(.top, StillSpacing.xs)
            }
        }
    }

    private func optionRow(icon: String, title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? StillColor.accent : StillColor.inkSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(StillFont.body(14))
                        .foregroundStyle(StillColor.ink)
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? StillColor.accent : StillColor.inkSecondary)
            }
            .padding(StillSpacing.md)
            .background(isSelected ? StillColor.accentDim : StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func checkboxRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(StillColor.inkSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(StillFont.body(14))
                        .foregroundStyle(StillColor.ink)
                    Text(subtitle)
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)
                }
                Spacer()
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn.wrappedValue ? StillColor.accent : StillColor.inkSecondary)
            }
            .padding(StillSpacing.md)
            .background(StillColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NewMemoryView()
}
