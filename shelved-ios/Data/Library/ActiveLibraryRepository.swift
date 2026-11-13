import Observation

/// Routes reads and writes to whichever library belongs to the current session
/// (the trial library or the signed-in user's library). Views only ever see this one.
@Observable
final class ActiveLibraryRepository: LibraryRepository {
    private(set) var current: any LibraryRepository

    init(_ initial: any LibraryRepository) {
        current = initial
    }

    func use(_ repository: any LibraryRepository) {
        current = repository
    }

    var snapshot: LibrarySnapshot { current.snapshot }

    func addGame(_ game: Game) { current.addGame(game) }
    func updateGame(_ game: Game) { current.updateGame(game) }
    func deleteGames(_ gameIds: Set<String>) { current.deleteGames(gameIds) }
    func updateProfile(_ profile: Profile) { current.updateProfile(profile) }
    func replaceLibrary(_ snapshot: LibrarySnapshot) { current.replaceLibrary(snapshot) }
}
