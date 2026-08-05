//
//  NotificationBell.swift
//  Still
//
//  The social entry point: friend shares and nearby-discovery alerts
//  only. No likes, comments, followers, or counters — just meaningful
//  notices, each written like a small sentence rather than a stat.
//
//  Wire `notifications` to a real feed once Supabase is in place.
//

import SwiftUI

struct StillNotification: Identifiable {
    enum Kind {
        case friendShare(from: String)
        case nearbyDiscovery(place: String)
    }

    let id: UUID
    let kind: Kind
    let date: Date
    var isRead: Bool

    var message: String {
        switch kind {
        case .friendShare(let from):
            return "\(from) shared a memory with you"
        case .nearbyDiscovery(let place):
            return "You discovered a memory near \(place)"
        }
    }
}

struct NotificationBell: View {
    @Binding var notifications: [StillNotification]
    @State private var showingPanel = false

    private var hasUnread: Bool { notifications.contains { !$0.isRead } }

    var body: some View {
        Button(action: { showingPanel = true }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .foregroundStyle(StillColor.ink)
                if hasUnread {
                    Circle()
                        .fill(StillColor.accent)
                        .frame(width: 6, height: 6)
                        .offset(x: 6, y: -4)
                }
            }
        }
        .sheet(isPresented: $showingPanel) {
            NotificationPanel(notifications: $notifications)
                .presentationDetents([.fraction(0.5), .large])
                .presentationBackground(StillColor.background)
        }
    }
}

private struct NotificationPanel: View {
    @Binding var notifications: [StillNotification]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(StillColor.divider)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, StillSpacing.sm)
                .padding(.bottom, StillSpacing.lg)

            if notifications.isEmpty {
                Spacer()
                Text("Nothing new")
                    .font(StillFont.caption(13))
                    .foregroundStyle(StillColor.inkSecondary.opacity(0.5))
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: StillSpacing.lg) {
                        ForEach(notifications) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.message)
                                    .font(StillFont.caption(14))
                                    .foregroundStyle(StillColor.ink.opacity(note.isRead ? 0.55 : 0.9))
                                Text(note.date.formatted(.relative(presentation: .named)))
                                    .font(StillFont.caption(11))
                                    .foregroundStyle(StillColor.inkSecondary.opacity(0.6))
                            }
                        }
                    }
                }
                .onAppear {
                    for i in notifications.indices { notifications[i].isRead = true }
                }
            }
        }
        .padding(.horizontal, StillSpacing.lg)
    }
}
