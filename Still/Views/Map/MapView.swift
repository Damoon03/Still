import SwiftUI
import MapKit

private enum MapDisplayMode {
    case map, list
}

struct MapView: View {
    @Environment(\.memoryRepository) private var memoryRepository

    @State private var mode: MapDisplayMode = .map
    @State private var filter: MemoryOrigin = .own   // My Memories is always the default
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7692, longitude: -122.4381),
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
    )

    // Real, repository-backed — this is the part that's no longer mock.
    @State private var ownItems: [MapMemoryItem] = []

    // Friends/Discoveries stay dummy until there's a real social backend.
    private var mockSocialItems: [MapMemoryItem] { MapMemoryItem.mockSocialData }

    private var allItems: [MapMemoryItem] { ownItems + mockSocialItems }

    @State private var selectedMemory: MapMemoryItem? = nil
    @State private var selectedDiscovery: MapMemoryItem? = nil
    @State private var pendingMemoryNavigationID: UUID? = nil
    @State private var path: [UUID] = []

    // Local-only until this is backed by Supabase.
    @State private var hiddenItemIDs: Set<UUID> = []
    @State private var blockedAuthors: Set<String> = []

    @State private var loadErrorMessage: String?

    private var visibleItems: [MapMemoryItem] {
        allItems
            .filter { $0.origin == filter }
            .filter { !hiddenItemIDs.contains($0.id) }
            .filter { $0.authorName.map { !blockedAuthors.contains($0) } ?? true }
    }

    /// Only items with a real coordinate can get a pin — memories
    /// saved without location (permission denied, capture failed)
    /// still show up in the lists, just not on the map itself.
    private var mappableItems: [MapMemoryItem] {
        visibleItems.filter { $0.coordinate != nil }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                topBar
                originFilter

                if let loadErrorMessage {
                    Text(loadErrorMessage)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.danger)
                        .padding(.horizontal, StillSpacing.md)
                        .padding(.bottom, StillSpacing.sm)
                }

                if mode == .map {
                    mapArea
                    recentList
                } else {
                    fullList
                }
            }
            .background(StillColor.background)
            .navigationBarHidden(true)
            .navigationDestination(for: UUID.self) { id in
                if let item = allItems.first(where: { $0.memory.id == id }) {
                    MemoryDetailView(memory: item.memory)
                }
            }
            .onAppear {
                // Re-runs on every reveal, including after popping
                // back from an edit/delete, not just on first mount.
                Task { await loadOwnMemories() }
            }
        }
        .sheet(item: $selectedMemory, onDismiss: {
            if let id = pendingMemoryNavigationID {
                pendingMemoryNavigationID = nil
                path.append(id)
            }
        }) { item in
            MemoryPreviewSheet(item: item, onOpenFullEntry: {
                pendingMemoryNavigationID = item.memory.id
            })
        }
        .sheet(item: $selectedDiscovery) { item in
            DiscoveryPreviewCard(
                item: item,
                onSave: { /* persist to saved memories once wired up */ },
                onHide: { hiddenItemIDs.insert(item.id) },
                onNeverShowAuthor: {
                    if let author = item.authorName { blockedAuthors.insert(author) }
                }
            )
        }
    }

    private func loadOwnMemories() async {
        guard let memoryRepository else { return }
        loadErrorMessage = nil
        do {
            let memories = try await memoryRepository.fetchAll()
            ownItems = memories.map {
                MapMemoryItem(id: $0.id, memory: $0, origin: .own, authorName: nil)
            }
            if let latest = ownItems.sorted(by: { $0.date > $1.date }).first,
               let coordinate = latest.coordinate {
                position = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        } catch {
            loadErrorMessage = "couldn't load your memories."
        }
    }

    private var topBar: some View {
        HStack(spacing: StillSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(StillColor.ink)

            Spacer()

            HStack(spacing: 2) {
                modeButton("map", .map)
                modeButton("list", .list)
            }
            .padding(3)
            .background(StillColor.surface)
            .clipShape(Capsule())

            Spacer()

            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(StillColor.ink)
        }
        .padding(StillSpacing.md)
    }

    /// My Memories / Friends / Discoveries — small and minimal, sits
    /// quietly above the map rather than acting like a social feed
    /// switcher.
    private var originFilter: some View {
        HStack(spacing: 2) {
            ForEach(MemoryOrigin.allCases) { origin in
                filterChip(origin)
            }
        }
        .padding(3)
        .background(StillColor.surface)
        .clipShape(Capsule())
        .padding(.horizontal, StillSpacing.md)
        .padding(.bottom, StillSpacing.sm)
    }

    private func filterChip(_ origin: MemoryOrigin) -> some View {
        let isSelected = filter == origin
        return Button(action: { filter = origin }) {
            Text(origin.label)
                .font(StillFont.caption(11))
                .foregroundStyle(isSelected ? StillColor.background : StillColor.inkSecondary)
                .padding(.horizontal, StillSpacing.sm)
                .padding(.vertical, 6)
                .background(isSelected ? chipColor(for: origin) : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func chipColor(for origin: MemoryOrigin) -> Color {
        switch origin {
        case .own: return StillColor.accent
        case .friend: return StillColor.friendMemory
        case .discovery: return StillColor.discoveryMemory
        }
    }

    private func modeButton(_ title: String, _ value: MapDisplayMode) -> some View {
        Button {
            mode = value
        } label: {
            Text(title)
                .font(StillFont.caption(12))
                .foregroundStyle(mode == value ? StillColor.background : StillColor.inkSecondary)
                .padding(.horizontal, StillSpacing.md)
                .padding(.vertical, 6)
                .background(mode == value ? StillColor.accent : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var mapArea: some View {
        Map(position: $position) {
            ForEach(mappableItems) { item in
                if let coordinate = item.coordinate {
                    Annotation(item.place, coordinate: coordinate) {
                        marker(for: item)
                            .onTapGesture {
                                if item.origin == .discovery {
                                    selectedDiscovery = item
                                } else {
                                    selectedMemory = item
                                }
                            }
                    }
                }
            }
        }
        .frame(height: 300)
        .colorScheme(.dark)
    }

    @ViewBuilder
    private func marker(for item: MapMemoryItem) -> some View {
        // The visible dot stays small on purpose, but the tappable
        // area around it doesn't — under ~44pt is genuinely hard to
        // hit reliably on a real device (Apple's own minimum
        // recommended touch target is 44x44pt).
        ZStack {
            dot(for: item)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func dot(for item: MapMemoryItem) -> some View {
        switch item.origin {
        case .own:
            Circle()
                .fill(StillColor.accent.opacity(item.recencyOpacity))
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(StillColor.background, lineWidth: 2))
        case .friend:
            Circle()
                .fill(StillColor.friendMemory.opacity(0.85))
                .frame(width: 11, height: 11)
                .overlay(Circle().stroke(StillColor.background, lineWidth: 2))
        case .discovery:
            Circle()
                .fill(StillColor.discoveryMemory.opacity(0.8))
                .frame(width: 11, height: 11)
                .overlay(Circle().stroke(StillColor.background, lineWidth: 2))
        }
    }

    private var recentList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                Capsule()
                    .fill(StillColor.divider)
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, StillSpacing.sm)

                Text(filter == .own ? "recent memories" : "recent \(filter.label.lowercased())")
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)

                if visibleItems.isEmpty {
                    Text(filter == .own ? "nothing here yet — write your first memory." : "nothing to show yet.")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary.opacity(0.6))
                        .padding(.top, StillSpacing.sm)
                }

                ForEach(visibleItems.prefix(4)) { item in
                    Button(action: {
                        if item.origin == .discovery { selectedDiscovery = item } else { selectedMemory = item }
                    }) {
                        MemoryRow(memory: item.memory)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(StillSpacing.md)
        }
    }

    private var fullList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                if visibleItems.isEmpty {
                    Text(filter == .own ? "nothing here yet — write your first memory." : "nothing to show yet.")
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary.opacity(0.6))
                        .padding(.top, StillSpacing.sm)
                }

                ForEach(visibleItems) { item in
                    Button(action: {
                        if item.origin == .discovery { selectedDiscovery = item } else { selectedMemory = item }
                    }) {
                        MemoryRow(memory: item.memory)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(StillSpacing.md)
        }
    }
}

#Preview {
    MapView()
}
