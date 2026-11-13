import Testing
@testable import shelved_ios

/// Port of Android `StatsMapperTest`.
struct StatsSummaryTests {
    @Test func emptyLibraryProducesEmptyStats() {
        let stats = StatsSummary(games: [])

        #expect(stats.totalGames == 0)
        #expect(stats.totalHours == 0)
        #expect(stats.completionRate == 0)
        #expect(stats.averageHoursPerTrackedGame == 0)
        #expect(stats.topPlatform == nil)
        #expect(stats.mostPlayedGames.isEmpty)
    }

    @Test func derivesSummaryProgressAndPlaytimeMetrics() {
        let games = [
            game("1", "Halo", .completed, 40, "Xbox", "PC"),
            game("2", "Forza", .playing, 20, "Xbox"),
            game("3", "Celeste", .completed, 10, "PC"),
            game("4", "Unplayed", .backlog, nil, "Switch"),
            game("5", "Zero", .backlog, 0, "Xbox"),
        ]

        let stats = StatsSummary(games: games)

        #expect(stats.totalGames == 5)
        #expect(stats.totalHours == 70)
        #expect(stats.completedGames == 2)
        #expect(stats.completionRate == 40)
        #expect(stats.trackedGames == 3)
        #expect(stats.averageHoursPerTrackedGame == 70.0 / 3.0)
        #expect(stats.topPlatform == "Xbox")
        #expect(stats.mostPlayedGames.map(\.name) == ["Halo", "Forza", "Celeste"])
    }

    @Test func platformAndPlaytimeTiesUseAlphabeticalOrder() {
        let games = [
            game("1", "Zelda", .playing, 12, "Switch"),
            game("2", "Astro Bot", .playing, 12, "PlayStation"),
        ]

        let stats = StatsSummary(games: games)

        #expect(stats.topPlatform == "PlayStation")
        #expect(stats.mostPlayedGames.map(\.name) == ["Astro Bot", "Zelda"])
    }

    private func game(
        _ id: String,
        _ name: String,
        _ status: GameStatus,
        _ hours: Int?,
        _ platforms: String...
    ) -> Game {
        Game(id: id, name: name, status: status, hoursPlayed: hours, platforms: platforms)
    }
}
