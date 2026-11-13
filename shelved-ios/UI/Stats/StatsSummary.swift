import Foundation

/// Everything the Stats screen shows, derived from the library. Port of Android `StatsMapper`.
nonisolated struct StatsSummary: Equatable {
    let totalGames: Int
    let totalHours: Int
    let statusCounts: [GameStatus: Int]
    let trackedGames: Int
    let topPlatform: String?
    let mostPlayedGames: [Game]

    init(games: [Game]) {
        let gamesWithPlaytime = games.filter { ($0.hoursPlayed ?? 0) > 0 }

        var statusCounts: [GameStatus: Int] = [:]
        for status in GameStatus.allCases {
            statusCounts[status] = games.count { $0.status == status }
        }

        // Each game counts once per platform, even if the catalog listed it twice.
        var platformCounts: [String: Int] = [:]
        for game in games {
            for platform in Set(game.platforms.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
                platformCounts[platform.trimmingCharacters(in: .whitespaces), default: 0] += 1
            }
        }

        totalGames = games.count
        totalHours = games.reduce(0) { $0 + max($1.hoursPlayed ?? 0, 0) }
        self.statusCounts = statusCounts
        trackedGames = gamesWithPlaytime.count
        topPlatform = platformCounts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key.lowercased() < $1.key.lowercased() }
            .first?.key
        mostPlayedGames = Array(
            gamesWithPlaytime
                .sorted {
                    let (left, right) = ($0.hoursPlayed ?? 0, $1.hoursPlayed ?? 0)
                    return left != right ? left > right : $0.name.lowercased() < $1.name.lowercased()
                }
                .prefix(3)
        )
    }

    var isEmpty: Bool { totalGames == 0 }
    var completedGames: Int { count(for: .completed) }
    var completionRate: Int { percentage(of: completedGames) }

    var averageHoursPerTrackedGame: Double {
        trackedGames == 0 ? 0 : Double(totalHours) / Double(trackedGames)
    }

    func count(for status: GameStatus) -> Int {
        statusCounts[status] ?? 0
    }

    func percentage(for status: GameStatus) -> Int {
        percentage(of: count(for: status))
    }

    private func percentage(of count: Int) -> Int {
        totalGames == 0 ? 0 : Int((Double(count) * 100 / Double(totalGames)).rounded())
    }
}
