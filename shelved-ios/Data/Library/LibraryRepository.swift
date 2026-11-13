/// The library contract shared by the persistent, trial, and active repositories.
/// Conforming types are `@Observable`, so views that read `games` or `profile` update automatically.
protocol LibraryRepository: AnyObject {
    var snapshot: LibrarySnapshot { get }

    func addGame(_ game: Game)
    func updateGame(_ game: Game)
    func deleteGames(_ gameIds: Set<String>)
    func updateProfile(_ profile: Profile)
    func replaceLibrary(_ snapshot: LibrarySnapshot)
}

extension LibraryRepository {
    var games: [Game] { snapshot.games }
    var profile: Profile { snapshot.profile }
}
