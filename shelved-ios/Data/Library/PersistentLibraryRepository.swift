import Observation
import OSLog

/// The device library for signed-in users. Updates the UI immediately, then saves in the background.
@Observable
final class PersistentLibraryRepository: LibraryRepository {
    private(set) var snapshot: LibrarySnapshot
    @ObservationIgnored private let writes: OrderedWriteQueue<LibrarySnapshot>

    init(fileStore: LibraryFileStore) {
        snapshot = fileStore.load()
        writes = OrderedWriteQueue(
            writer: { try fileStore.save($0) },
            onError: { Logger.library.error("Could not save the library. \($0)") }
        )
    }

    func addGame(_ game: Game) { mutate { $0.addGame(game) } }
    func updateGame(_ game: Game) { mutate { $0.updateGame(game) } }
    func deleteGames(_ gameIds: Set<String>) { mutate { $0.deleteGames(gameIds) } }
    func updateProfile(_ profile: Profile) { mutate { $0.profile = profile } }
    func replaceLibrary(_ snapshot: LibrarySnapshot) { mutate { $0 = snapshot } }

    /// Waits for every queued save to reach disk. No later changes are saved, so tests call this last.
    func finishWrites() async {
        await writes.drain()
    }

    private func mutate(_ change: (inout LibrarySnapshot) -> Void) {
        var updated = snapshot
        change(&updated)
        guard updated != snapshot else { return }
        snapshot = updated
        writes.enqueue(updated)
    }
}
