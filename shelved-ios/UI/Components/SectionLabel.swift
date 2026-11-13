import SwiftUI

/// Small uppercase heading used above each section, like Android's `SectionLabel`.
struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.bold())
            .tracking(0.7)
            .foregroundStyle(.textMuted)
            .padding(.top, 10)
            .accessibilityAddTraits(.isHeader)
    }
}
