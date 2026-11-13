import Observation

/// Process-local library used by Try mode. Nothing is written to disk.
@Observable
final class InMemoryLibraryRepository: LibraryRepository {
    private(set) var snapshot: LibrarySnapshot

    init(snapshot: LibrarySnapshot = LibrarySnapshot()) {
        self.snapshot = snapshot
    }

    func addGame(_ game: Game) { snapshot.addGame(game) }
    func updateGame(_ game: Game) { snapshot.updateGame(game) }
    func deleteGames(_ gameIds: Set<String>) { snapshot.deleteGames(gameIds) }
    func updateProfile(_ profile: Profile) { snapshot.profile = profile }
    func replaceLibrary(_ snapshot: LibrarySnapshot) { self.snapshot = snapshot }
}
