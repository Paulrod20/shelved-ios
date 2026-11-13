import Foundation
import Testing
@testable import shelved_ios

/// iOS-only: the Android store had no direct tests, but this one owns the user's data on disk.
@MainActor
struct PersistentLibraryRepositoryTests {
    private let fileStore = LibraryFileStore(
        fileURL: URL.temporaryDirectory.appending(path: "library-\(UUID().uuidString).json")
    )

    @Test func missingFileStartsAnEmptyLibrary() {
        #expect(fileStore.load() == LibrarySnapshot())
    }

    @Test func changesAreSavedAndReloadedOnNextLaunch() async {
        let firstLaunch = PersistentLibraryRepository(fileStore: fileStore)
        firstLaunch.addGame(Game(id: "igdb:1", name: "Saved game", rating: Rating(5)))
        firstLaunch.updateProfile(Profile(displayName: "Player"))
        await firstLaunch.finishWrites()

        let nextLaunch = PersistentLibraryRepository(fileStore: fileStore)

        #expect(nextLaunch.snapshot == firstLaunch.snapshot)
        #expect(nextLaunch.games.first?.rating?.value == 5)
    }

    @Test func unreadableFileIsMovedAsideInsteadOfOverwritten() throws {
        try Data("not json".utf8).write(to: fileStore.fileURL)

        let snapshot = fileStore.load()

        let folder = fileStore.fileURL.deletingLastPathComponent()
        let baseName = fileStore.fileURL.deletingPathExtension().lastPathComponent
        let setAside = try FileManager.default.contentsOfDirectory(atPath: folder.path())
            .filter { $0.hasPrefix(baseName + ".unreadable-") }
        #expect(snapshot == LibrarySnapshot())
        #expect(!FileManager.default.fileExists(atPath: fileStore.fileURL.path()))
        #expect(setAside.count == 1)
    }
}
