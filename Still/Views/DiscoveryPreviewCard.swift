//
//  DiscoveryPreviewCard.swift
//  Still
//
//  Shown when a user taps a Discovery marker. Feels like finding
//  something, not browsing a feed — a single beautiful card with
//  quiet controls to save, dismiss, or opt out of a person entirely.
//  No "discovered count", no streaks, no sense of collecting.
//

import SwiftUI

struct DiscoveryPreviewCard: View {
    let item: MapMemoryItem
    var onSave: () -> Void
    var onHide: () -> Void
    var onNeverShowAuthor: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var dateText: String {
        item.date.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: StillSpacing.lg) {
            Capsule()
                .fill(StillColor.divider)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, StillSpacing.sm)

            HStack(spacing: 6) {
                Circle()
                    .fill(StillColor.discoveryMemory)
                    .frame(width: 6, height: 6)
                Text("a memory left nearby")
                    .font(StillFont.caption(11))
                    .foregroundStyle(StillColor.discoveryMemory)
                    .kerning(1)
            }

            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                Text(item.memory.title)
                    .font(StillFont.caption(22))
                    .foregroundStyle(StillColor.ink)

                HStack(spacing: 6) {
                    Text(item.place)
                    if let author = item.authorName {
                        Text(author)
                    }
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

            VStack(spacing: StillSpacing.sm) {
                Button(action: { onSave(); dismiss() }) {
                    Text("Save this memory")
                        .font(StillFont.caption(13))
                        .foregroundStyle(StillColor.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(StillColor.ink)
                        .clipShape(Capsule())
                }

                HStack(spacing: StillSpacing.md) {
                    Button(action: { onHide(); dismiss() }) {
                        Text("Hide")
                            .font(StillFont.caption(12))
                            .foregroundStyle(StillColor.inkSecondary)
                    }
                    Spacer()
                    if item.authorName != nil {
                        Button(action: { onNeverShowAuthor(); dismiss() }) {
                            Text("Never show this person again")
                                .font(StillFont.caption(12))
                                .foregroundStyle(StillColor.inkSecondary.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.bottom, StillSpacing.md)
        }
        .padding(.horizontal, StillSpacing.lg)
        .presentationDetents([.fraction(0.55), .large])
        .presentationBackground(StillColor.background)
    }
}
