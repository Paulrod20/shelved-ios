/// App-wide dependencies, created once at launch. No DI framework needed.
/// Slice 6 adds the trial library and switches `library` on sign-in and sign-out.
final class AppContainer {
    let persistentLibrary: PersistentLibraryRepository
    let library: ActiveLibraryRepository

    init(fileStore: LibraryFileStore = .standard) {
        persistentLibrary = PersistentLibraryRepository(fileStore: fileStore)
        library = ActiveLibraryRepository(persistentLibrary)
    }
}
