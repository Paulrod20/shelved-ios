import Foundation
import Testing
@testable import shelved_ios

/// Port of Android `GameJsonCodecTest`, plus profile coverage for the iOS file format.
struct StoredLibraryCodecTests {
    @Test func ratingAndPrivateReviewSurviveDeviceStorageRoundTrip() throws {
        let game = Game(
            id: "game",
            name: "Game",
            coverImageUrl: "https://example.com/cover.jpg",
            customCoverImagePath: "cover_1.jpg",
            status: .completed,
            hoursPlayed: 24,
            rating: Rating(4),
            review: "A thoughtful private review.",
            notes: [GameNote(text: "Private note", createdAtEpochMillis: 123)],
            released: "2026",
            playtime: 20,
            platforms: ["PC"],
            description: "Description"
        )

        let decoded = try JSONDecoder().decode(Game.self, from: JSONEncoder().encode(game))

        #expect(decoded == game)
    }

    @Test func olderStoredGamesDefaultToNoRatingOrReview() throws {
        let json = Data(#"{"id":"legacy","name":"Legacy game"}"#.utf8)

        let game = try JSONDecoder().decode(Game.self, from: json)

        #expect(game.rating == nil)
        #expect(game.review == "")
        #expect(game.status == .backlog)
        #expect(game.notes.isEmpty)
    }

    @Test func invalidStoredRatingAndStatusFallBackToDefaults() throws {
        let json = Data(#"{"id":"bad","name":"Bad","rating":10,"status":"WISHLIST"}"#.utf8)

        let game = try JSONDecoder().decode(Game.self, from: json)

        #expect(game.rating == nil)
        #expect(game.status == .backlog)
    }

    @Test func profileRoundTripsAndDropsUnknownPlatforms() throws {
        let profile = Profile(
            displayName: "Player",
            bio: "Bio",
            profileImagePath: "avatar_1.jpg",
            favoritePlatforms: [.pc, .handheld],
            favoriteGameIds: ["igdb:1"]
        )
        let json = Data(#"{"favoritePlatforms":["PC","SWITCH","PC","XBOX"]}"#.utf8)

        let roundTripped = try JSONDecoder().decode(Profile.self, from: JSONEncoder().encode(profile))
        let withUnknown = try JSONDecoder().decode(Profile.self, from: json)

        #expect(roundTripped == profile)
        #expect(withUnknown.favoritePlatforms == [.pc, .xbox])
    }
}
