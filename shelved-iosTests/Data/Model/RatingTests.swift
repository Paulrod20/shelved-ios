import Testing
@testable import shelved_ios

/// Port of Android `GameTest`.
struct RatingTests {
    @Test func ratingMustBeBetweenOneAndFive() {
        #expect(Rating(0) == nil)
        #expect(Rating(6) == nil)
        #expect(Rating(5)?.value == 5)
        #expect(Game(id: "unrated", name: "Unrated").rating == nil)
    }
}
