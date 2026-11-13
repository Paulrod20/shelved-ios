import SwiftUI

/// Top of the view tree. For now it only proves the theme and library load;
/// slice 2 replaces the body with the tab view, and slice 6 adds the onboarding gate.
struct RootView: View {
    let container: AppContainer

    var body: some View {
        VStack(spacing: 8) {
            Text("Shelved")
                .font(.largeTitle.bold())
                .foregroundStyle(.textPrimary)
            Text("\(container.library.games.count) games on your shelf")
                .font(.subheadline)
                .foregroundStyle(.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView(container: AppContainer(fileStore: LibraryFileStore(
        fileURL: URL.temporaryDirectory.appending(path: "preview-library.json")
    )))
}
