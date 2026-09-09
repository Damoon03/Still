//
//  MemoryPreviewSheet.swift
//  Still
//
//  Opens when tapping any memory marker on the map (own or friend's).
//  Reads like a page from a journal, not an info card — generous
//  space, quiet typography, no metadata clutter.
//

import SwiftUI

struct MemoryPreviewSheet: View {
    let item: MapMemoryItem
    var onOpenFullEntry: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private var dateText: String {
        item.date.formatted(.dateTime.month(.wide).day().year())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: StillSpacing.lg) {
            Capsule()
                .fill(StillColor.divider)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, StillSpacing.sm)

            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                if let author = item.authorName {
                    Text(item.origin == .friend ? "from \(author)" : author)
                        .font(StillFont.caption(12))
                        .foregroundStyle(StillColor.inkSecondary)
                }

                Text(item.memory.title)
                    .font(StillFont.caption(22))
                    .foregroundStyle(StillColor.ink)

                HStack(spacing: 6) {
                    Text(item.place)
                    Text(dateText)
                }
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary.opacity(0.7))
            }

            if let preview = item.previewText {
                Text(preview)
                    .font(StillFont.caption(15))
                    .foregroundStyle(StillColor.inkSecondary)
                    .lineSpacing(6)
            }

            Spacer()

            if let onOpenFullEntry {
                Button(action: {
                    dismiss()
                    onOpenFullEntry()
                }) {
                    Text("Open full entry")
                        .font(StillFont.caption(13))
                        .foregroundStyle(StillColor.ink)
                }
                .padding(.bottom, StillSpacing.md)
            }
        }
        .padding(.horizontal, StillSpacing.lg)
        .presentationDetents([.fraction(0.45), .large])
        .presentationBackground(StillColor.background)
    }
}
