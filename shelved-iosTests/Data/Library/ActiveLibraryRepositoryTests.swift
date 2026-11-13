import Testing
@testable import shelved_ios

/// Port of Android `ActiveLibraryRepositoryTest`.
@MainActor
struct ActiveLibraryRepositoryTests {
    @Test func switchingLibrariesUpdatesReadsAndRoutesFutureWrites() {
        let trial = InMemoryLibraryRepository()
        trial.addGame(Game(id: "trial", name: "Trial game"))
        let persistent = InMemoryLibraryRepository()
        persistent.addGame(Game(id: "saved", name: "Saved game"))
        let active = ActiveLibraryRepository(trial)

        #expect(active.games.map(\.id) == ["trial"])

        active.use(persistent)
        active.addGame(Game(id: "new", name: "New game"))

        #expect(active.games.map(\.id) == ["new", "saved"])
        #expect(persistent.games.map(\.id) == ["new", "saved"])
        #expect(!trial.games.contains { $0.id == "new" })
    }
}
