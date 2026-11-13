import SwiftUI

struct StatsView: View {
    let viewModel: StatsViewModel

    var body: some View {
        let summary = viewModel.summary
        NavigationStack {
            Group {
                if summary.isEmpty {
                    EmptyLibrary()
                } else {
                    ScrollView {
                        StatsContent(summary: summary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .navigationTitle("Stats")
        }
    }
}

private struct StatsContent: View {
    let summary: StatsSummary

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            StatsSummaryCard(summary: summary)

            SectionLabel("Library progress")
            LibraryProgressCard(summary: summary)

            SectionLabel("Your playtime")
            PlaytimeInsights(summary: summary)

            if !summary.mostPlayedGames.isEmpty {
                SectionLabel("Most played")
                ForEach(Array(summary.mostPlayedGames.enumerated()), id: \.element.id) { index, game in
                    MostPlayedGameRow(rank: index + 1, game: game)
                }
            }
        }
    }
}

#Preview("With games") {
    let library = InMemoryLibraryRepository(snapshot: LibrarySnapshot(games: [
        Game(id: "1", name: "Halo Infinite", status: .completed, hoursPlayed: 40, platforms: ["Xbox", "PC"]),
        Game(id: "2", name: "Forza Horizon 5", status: .playing, hoursPlayed: 20, platforms: ["Xbox"]),
        Game(id: "3", name: "Celeste", status: .completed, hoursPlayed: 10, platforms: ["PC"]),
        Game(id: "4", name: "Hades II", status: .backlog, platforms: ["PC"]),
    ]))
    StatsView(viewModel: StatsViewModel(library: library))
        .preferredColorScheme(.dark)
}

#Preview("Empty") {
    StatsView(viewModel: StatsViewModel(library: InMemoryLibraryRepository()))
        .preferredColorScheme(.dark)
}
