import SwiftUI

struct BookmarksView: View {
    private let saved = Array(Memory.dummyData.prefix(3))

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StillSpacing.sm) {
                    ForEach(saved) { memory in
                        NavigationLink(destination: MemoryDetailView(memory: memory)) {
                            MemoryRow(memory: memory)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(StillSpacing.md)
            }
            .background(StillColor.background)
            .navigationTitle("saved")
        }
    }
}

#Preview {
    BookmarksView()
}
