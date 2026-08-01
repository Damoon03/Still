import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showingNewMemory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StillSpacing.lg) {
                    header
                    greetingRow
                    todaySection
                    thisWeekSection
                    activitySection
                }
                .padding(StillSpacing.md)
                .padding(.bottom, StillSpacing.xl)
            }
            .background(StillColor.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNewMemory) {
                NewMemoryView()
            }
        }
    }

    private var header: some View {
        HStack {
            NavigationLink(destination: DiscoverView()) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundStyle(StillColor.ink)
            }

            Spacer()

            HStack {
                Circle()
                    .fill(StillColor.accent)
                    .frame(width: 7, height: 7)

                Text("Still")
                    .foregroundStyle(.white)
                    .monospaced()
                    .font(.system(size: 18))
                    .kerning(2)
            }
            .padding(.trailing, 5)

            Spacer()

            NotificationBell(notifications: $viewModel.notifications)
        }
    }

    private var greetingRow: some View {
        HStack(alignment: .top) {
            Text("Overview")
                .font(StillFont.title(25))
                .foregroundStyle(StillColor.ink)
                .lineSpacing(2)
            Spacer()
        }
    }

    // MARK: - Today

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("today")
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)

            HStack(spacing: StillSpacing.sm) {
                if let memory = viewModel.todayMemory {
                    NavigationLink(destination: MemoryDetailView(memory: memory)) {
                        todayMemoryCard(memory)
                    }
                    .buttonStyle(.plain)
                }

                if let onThisDay = viewModel.onThisDay {
                    NavigationLink(destination: MemoryDetailView(memory: onThisDay.memory)) {
                        onThisDayCard(onThisDay)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func todayMemoryCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            HStack(spacing: 4) {
                Image(systemName: "mappin")
                    .font(.system(size: 11))
                Text(memory.date.formatted(date: .omitted, time: .shortened).lowercased())
                    .font(StillFont.caption(11))
            }
            .foregroundStyle(StillColor.inkSecondary)

            Text(memory.title)
                .font(StillFont.heading(14))
                .foregroundStyle(StillColor.ink)

            Text(memory.text)
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(StillSpacing.md)
        .background(StillColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.lg, style: .continuous))
    }

    /// A quiet reminder, not a stat — same size and language as the
    /// today card, but held back so it never reads louder than the
    /// user's current memory.
    private func onThisDayCard(_ onThisDay: OnThisDayMemory) -> some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("on this day")
                .font(StillFont.caption(11))
                .foregroundStyle(StillColor.inkSecondary)


            Text("\(onThisDay.yearsAgo) year\(onThisDay.yearsAgo == 1 ? "" : "s") ago")
                .font(StillFont.heading(14))
                .foregroundStyle(StillColor.ink.opacity(0.85))
                .padding(.bottom)

            Text(onThisDay.memory.place)
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)
                .lineLimit(1)
            Spacer(minLength: StillSpacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(StillSpacing.md)
        .background(StillColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.lg, style: .continuous))
    }

    // MARK: - This week

    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("this week")
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)
                .padding(.leading, 5)

            HStack(spacing: StillSpacing.sm) {
                statTile(icon: "mappin", value: "\(viewModel.placesThisWeekCount)", label: "places")
                statTile(icon: "square.stack", value: "\(viewModel.memoriesThisWeekCount)", label: "memories")
                statTile(icon: "heart", value: "\(viewModel.revisitedThisWeekCount)", label: "revisited")
            }
        }
    }

    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(StillColor.accent)
                Text(value)
                    .font(StillFont.heading(16))
                    .foregroundStyle(StillColor.ink)
            }
            Text(label)
                .font(StillFont.caption(11))
                .foregroundStyle(StillColor.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(StillSpacing.sm + 4)
        .background(StillColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: StillRadius.md, style: .continuous))
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            HStack {
                Text("activity")
                    .font(StillFont.caption(12))
                    .foregroundStyle(StillColor.inkSecondary)
                    .padding(.leading, 8)

                Spacer()
                Text("\(Int(viewModel.activityValues.max() ?? 0))")
                    .font(StillFont.heading(12))
                    .foregroundStyle(StillColor.accent)
                    .padding(.trailing)
            }

            Card {
                VStack(alignment: .leading, spacing: StillSpacing.sm) {
                    Text("memories over time")
                        .font(StillFont.caption(11))
                        .foregroundStyle(StillColor.inkSecondary)

                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(Array(viewModel.activityValues.enumerated()), id: \.offset) { _, value in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(StillColor.accent)
                                .frame(width: 8, height: max(4, value * 6))
                        }
                    }
                    .frame(height: 56, alignment: .bottom)

                    HStack {
                        ForEach(viewModel.weekdayLabels, id: \.self) { day in
                            Text(day)
                                .font(StillFont.caption(10))
                                .foregroundStyle(StillColor.inkSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
