import Observation

/// Supplies the Stats screen. The summary is recomputed from the library whenever the games change.
@Observable
final class StatsViewModel {
    private let library: any LibraryRepository

    init(library: any LibraryRepository) {
        self.library = library
    }

    var summary: StatsSummary {
        StatsSummary(games: library.games)
    }
}
