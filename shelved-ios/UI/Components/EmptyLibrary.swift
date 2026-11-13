import SwiftUI

/// Empty state for the whole shelf or for a filtered section.
struct EmptyLibrary: View {
    /// True when the library has no games at all; false when only a filter is empty.
    var isWholeLibrary = true
    var onAdd: (() -> Void)?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 40))
                .foregroundStyle(.textMuted)
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            Text(isWholeLibrary ? "Your shelf is empty" : "Nothing in this section")
                .font(.body.weight(.semibold))
                .foregroundStyle(.textPrimary)
            Text(isWholeLibrary ? "Add a game to start your collection." : "Try another status.")
                .font(.footnote)
                .foregroundStyle(.textMuted)
            if isWholeLibrary, let onAdd {
                Button("Add your first game", action: onAdd)
                    .tint(.accentColor)
                    .padding(.top, 6)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
