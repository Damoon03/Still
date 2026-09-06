import SwiftUI

struct HomeView: View {
    @Environment(\.memoryRepository) private var memoryRepository
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StillSpacing.lg) {
                    header
                    greetingRow

                    if let loadErrorMessage = viewModel.loadErrorMessage {
                        Text(loadErrorMessage)
                            .font(StillFont.caption(12))
                            .foregroundStyle(StillColor.danger)
                    }

                    todaySection
                    thisWeekSection
                    activitySection
                    reflectionSection
                }
                .padding(StillSpacing.md)
                .padding(.bottom, StillSpacing.xl)
            }
            .background(StillColor.background)
            .navigationBarHidden(true)
            .onAppear {
                // Re-runs whenever this screen is revealed again —
                // including after popping back from an edit/delete —
                // not just on first mount, so it never shows stale data.
                if let memoryRepository {
                    viewModel.configure(repository: memoryRepository)
                }
                Task { await viewModel.refresh() }
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
            Text("Home")
                .font(StillFont.title(25))
                .foregroundStyle(StillColor.ink)
                .lineSpacing(2)
            Spacer()
        }
    }

    // MARK: - Today

    /// Up to two quiet cards: today's memory (or a gentle empty
    /// state if nothing's been recorded yet) and, when one exists,
    /// an "on this day" memory from a previous year. No compose
    /// entry point here — that's what the global + button is for,
    /// and a second one just competes with it.
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
                } else {
                    emptyTodayCard
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

    private var emptyTodayCard: some View {
        VStack(alignment: .leading, spacing: StillSpacing.sm) {
            Text("nothing recorded yet.")
                .font(StillFont.body(14))
                .foregroundStyle(StillColor.inkSecondary)
            Text("when something's worth keeping,\ncome back here.")
                .font(StillFont.caption(11))
                .foregroundStyle(StillColor.inkSecondary)
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

            Spacer(minLength: StillSpacing.sm)

            Text("\(onThisDay.yearsAgo) year\(onThisDay.yearsAgo == 1 ? "" : "s") ago")
                .font(StillFont.heading(14))
                .foregroundStyle(StillColor.ink.opacity(0.85))

            Text(onThisDay.memory.place)
                .font(StillFont.caption(12))
                .foregroundStyle(StillColor.inkSecondary)
                .lineLimit(1)
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

    /// The busiest day in the current data — every bar's height is
    /// relative to this, not to a fixed absolute count.
    private var maxActivityValue: CGFloat {
        viewModel.activityValues.max() ?? 0
    }

    private let maxBarHeight: CGFloat = 60
    private let chartRowHeight: CGFloat = 72

    /// One memory on an otherwise-empty week should read as a full
    /// bar, not a sliver — it *is* the most that happened all week.
    /// Ten memories on Monday and one on Tuesday should read as
    /// full vs. nearly-empty, not both "tall enough." Height is
    /// proportional to the busiest day, never absolute.
    private func barHeight(for value: CGFloat) -> CGFloat {
        guard maxActivityValue > 0 else { return 4 }
        return max(4, (value / maxActivityValue) * maxBarHeight)
    }

    /// No external heading — the card stands on its own, with
    /// "memories over time" as its only label.
    private var activitySection: some View {
        Card {
            VStack(alignment: .leading, spacing: StillSpacing.sm) {
                Text("memories over time")
                    .font(StillFont.caption(11))
                    .foregroundStyle(StillColor.inkSecondary)

                if maxActivityValue > 0 {
                    HStack(alignment: .bottom) {
                        ForEach(Array(viewModel.activityValues.enumerated()), id: \.offset) { _, value in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(StillColor.accent)
                                .frame(width: 10, height: barHeight(for: value))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: chartRowHeight, alignment: .bottom)

                    HStack {
                        ForEach(viewModel.weekdayLabels, id: \.self) { day in
                            Text(day)
                                .font(StillFont.caption(10))
                                .foregroundStyle(StillColor.inkSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    // The card itself communicates the empty
                    // state rather than showing a chart that's
                    // just seven 4pt nubs — that reads as broken,
                    // not "nothing yet."
                    Text("your weeks will begin to take shape here")
                        .font(StillFont.caption(13))
                        .foregroundStyle(StillColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: chartRowHeight + 14)
                }
            }
            .padding(.vertical, StillSpacing.xs)
        }
    }

    // MARK: - Reflection

    /// Deliberately not a Card — no background, no border, just
    /// typography and space. A closing thought, not another widget.
    /// The Home screen ends here now — no second compose prompt.
    private var reflectionSection: some View {
        Text(viewModel.reflectionLine)
            .font(StillFont.body(15))
            .foregroundStyle(StillColor.inkSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, StillSpacing.lg)
    }
}

#Preview {
    HomeView()
}
