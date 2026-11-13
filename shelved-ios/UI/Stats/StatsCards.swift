import SwiftUI

/// Games, Hours, Completed, and Completion %.
struct StatsSummaryCard: View {
    let summary: StatsSummary

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryMetric(value: "\(summary.totalGames)", label: "Games")
                SummaryMetric(value: "\(summary.totalHours)", label: "Hours")
            }
            Divider().overlay(Color.border)
            HStack(spacing: 16) {
                SummaryMetric(value: "\(summary.completedGames)", label: "Completed", isCompact: true)
                SummaryMetric(value: "\(summary.completionRate)%", label: "Completion", isCompact: true)
            }
        }
        .padding(20)
        .background(.surface, in: .rect(cornerRadius: 20))
    }
}

private struct SummaryMetric: View {
    let value: String
    let label: String
    var isCompact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font((isCompact ? Font.title2 : .largeTitle).bold())
                .tracking(-0.6)
                .foregroundStyle(Color.accentColor)
            Text(label)
                .font(.footnote)
                .foregroundStyle(.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Segmented bar plus one legend row per status.
struct LibraryProgressCard: View {
    let summary: StatsSummary

    var body: some View {
        VStack(spacing: 18) {
            SegmentedProgressBar(summary: summary)
            ForEach(GameStatus.allCases, id: \.self) { status in
                ProgressLegendRow(
                    label: status.label,
                    count: summary.count(for: status),
                    percentage: summary.percentage(for: status),
                    color: status.progressColor
                )
            }
        }
        .padding(18)
        .background(.surface, in: .rect(cornerRadius: 18))
    }
}

private struct SegmentedProgressBar: View {
    let summary: StatsSummary

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(GameStatus.allCases, id: \.self) { status in
                    let count = summary.count(for: status)
                    if count > 0 {
                        status.progressColor
                            .frame(width: proxy.size.width * CGFloat(count) / CGFloat(max(summary.totalGames, 1)))
                    }
                }
            }
        }
        .frame(height: 12)
        .background(.border)
        .clipShape(.rect(cornerRadius: 6))
        .accessibilityHidden(true) // The legend rows carry the same numbers for VoiceOver.
    }
}

private struct ProgressLegendRow: View {
    let label: String
    let count: Int
    let percentage: Int
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
            Text("\(percentage)%")
                .font(.footnote)
                .foregroundStyle(.textMuted)
                .frame(minWidth: 36, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Average hours per tracked game and the most common platform.
struct PlaytimeInsights: View {
    let summary: StatsSummary

    var body: some View {
        HStack(spacing: 12) {
            InsightCard(value: formattedHours(summary.averageHoursPerTrackedGame), label: "Avg. tracked game")
            InsightCard(value: summary.topPlatform ?? "—", label: "Top platform")
        }
    }

    private func formattedHours(_ hours: Double) -> String {
        hours == 0 ? "—" : "\(hours.formatted(.number.precision(.fractionLength(0...1))))h"
    }
}

private struct InsightCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.textPrimary)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(.horizontal, 16)
        .background(.surface, in: .rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

/// One of the top three games by hours played.
struct MostPlayedGameRow: View {
    let rank: Int
    let game: Game

    var body: some View {
        HStack(spacing: 0) {
            Text("#\(rank)")
                .font(.caption.bold())
                .foregroundStyle(.textMuted)
                .padding(.horizontal, 6)
            GameThumbnail(game: game)
            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                Text(game.status.label)
                    .font(.caption)
                    .foregroundStyle(.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            Text("\(game.hoursPlayed ?? 0)h")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, 6)
        }
        .padding(10)
        .background(.surface, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Number \(rank), \(game.name), \(game.status.label), \(game.hoursPlayed ?? 0) hours")
    }
}

/// Small cover with a controller placeholder. Custom covers are added with the image store in slice 5.
private struct GameThumbnail: View {
    let game: Game

    var body: some View {
        AsyncImage(url: game.coverImageUrl.flatMap(URL.init(string:))) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "gamecontroller")
                .font(.title3)
                .foregroundStyle(.textMuted)
        }
        .frame(width: 46, height: 64)
        .background(.surfaceElevated)
        .clipShape(.rect(cornerRadius: 9))
    }
}

private extension GameStatus {
    var progressColor: Color {
        switch self {
        case .backlog: .statusBacklog
        case .playing: .statusPlaying
        case .completed: .accentColor
        }
    }
}
