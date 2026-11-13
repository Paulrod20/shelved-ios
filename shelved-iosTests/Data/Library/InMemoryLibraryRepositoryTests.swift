import Testing
@testable import shelved_ios

/// Port of Android `InMemoryLibraryRepositoryTest`, plus the shared mutation rules.
@MainActor
struct InMemoryLibraryRepositoryTests {
    @Test func aNewTrialRepositoryAlwaysStartsEmpty() {
        let firstSession = InMemoryLibraryRepository()
        firstSession.addGame(Game(id: "trial", name: "Trial game"))

        let nextSession = InMemoryLibraryRepository()

        #expect(firstSession.games.map(\.id) == ["trial"])
        #expect(nextSession.games.isEmpty)
    }

    @Test func newGamesGoFirstAndDuplicatesAreIgnored() {
        let library = InMemoryLibraryRepository()
        library.addGame(Game(id: "first", name: "First"))
        library.addGame(Game(id: "second", name: "Second"))
        library.addGame(Game(id: "first", name: "Duplicate"))

        #expect(library.games.map(\.id) == ["second", "first"])
        #expect(library.games.last?.name == "First")
    }

    @Test func deletingGamesAlsoRemovesThemFromFavorites() {
        let library = InMemoryLibraryRepository()
        library.addGame(Game(id: "kept", name: "Kept"))
        library.addGame(Game(id: "gone", name: "Gone"))
        library.updateProfile(Profile(favoriteGameIds: ["gone", "kept"]))

        library.deleteGames(["gone"])

        #expect(library.games.map(\.id) == ["kept"])
        #expect(library.profile.favoriteGameIds == ["kept"])
    }
}
