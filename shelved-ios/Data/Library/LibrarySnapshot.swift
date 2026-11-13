/// The whole library as one value: games (newest first) plus the profile.
/// Repositories mutate a copy and publish it, so every change is one atomic swap.
nonisolated struct LibrarySnapshot: Hashable, Codable, Sendable {
    var games: [Game] = []
    var profile = Profile()

    /// Adds a game to the top of the shelf. Duplicate IDs are ignored.
    mutating func addGame(_ game: Game) {
        guard !games.contains(where: { $0.id == game.id }) else { return }
        games.insert(game, at: 0)
    }

    mutating func updateGame(_ game: Game) {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        games[index] = game
    }

    /// Removes the games and drops them from the profile's favorites.
    mutating func deleteGames(_ gameIds: Set<String>) {
        guard !gameIds.isEmpty else { return }
        games.removeAll { gameIds.contains($0.id) }
        profile.favoriteGameIds.removeAll { gameIds.contains($0) }
    }
}
