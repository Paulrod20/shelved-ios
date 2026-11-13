import Foundation
import OSLog

/// Reads and writes the library as one JSON file.
/// Safe to call from any thread; it holds no mutable state.
nonisolated struct LibraryFileStore: Sendable {
    let fileURL: URL

    static let standard = LibraryFileStore(
        fileURL: URL.applicationSupportDirectory.appending(path: "library.json")
    )

    /// A missing file is an empty library. An unreadable file is moved aside, not overwritten,
    /// so a decoding bug can never silently erase someone's shelf.
    func load() -> LibrarySnapshot {
        guard let data = try? Data(contentsOf: fileURL) else { return LibrarySnapshot() }
        do {
            return try JSONDecoder().decode(LibrarySnapshot.self, from: data)
        } catch {
            Logger.library.error("Library file is unreadable; moving it aside. \(error)")
            quarantineUnreadableFile()
            return LibrarySnapshot()
        }
    }

    func save(_ snapshot: LibrarySnapshot) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    private func quarantineUnreadableFile() {
        let stamp = Int(Date().timeIntervalSince1970)
        let destination = fileURL.deletingPathExtension().appendingPathExtension("unreadable-\(stamp).json")
        try? FileManager.default.moveItem(at: fileURL, to: destination)
    }
}

nonisolated extension Logger {
    static let library = Logger(subsystem: "com.paulrod.shelved", category: "Library")
}
