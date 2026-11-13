import SwiftUI

/// Top of the view tree. Slice 6 adds the onboarding gate and the account screen here.
struct RootView: View {
    let container: AppContainer

    var body: some View {
        MainTabView(container: container)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView(container: AppContainer(fileStore: LibraryFileStore(
        fileURL: URL.temporaryDirectory.appending(path: "preview-library.json")
    )))
}
