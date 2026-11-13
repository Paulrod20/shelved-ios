/// Raw values match the Android app and the Firestore schema exactly.
nonisolated enum GameStatus: String, Codable, CaseIterable, Sendable {
    case backlog = "BACKLOG"
    case playing = "PLAYING"
    case completed = "COMPLETED"
}

nonisolated struct GameNote: Hashable, Codable, Sendable {
    var text: String
    var createdAtEpochMillis: Int64
}

nonisolated struct Game: Identifiable, Hashable, Sendable {
    /// `igdb:<id>` for catalog games; legacy RAWG games use a bare number.
    let id: String
    var name: String
    var coverImageUrl: String?
    /// File name inside the managed cover directory, never an absolute path.
    var customCoverImagePath: String?
    var status: GameStatus = .backlog
    var hoursPlayed: Int?
    var rating: Rating?
    var review: String = ""
    var notes: [GameNote] = []
    var released: String?
    var playtime: Int?
    var platforms: [String] = []
    var description: String?
}

extension Game: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, coverImageUrl, customCoverImagePath, status, hoursPlayed
        case rating, review, notes, released, playtime, platforms, description
    }

    /// Missing or invalid fields fall back to defaults, like the Android reader.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
        customCoverImagePath = try container.decodeIfPresent(String.self, forKey: .customCoverImagePath)
        let storedStatus = try container.decodeIfPresent(String.self, forKey: .status)
        status = storedStatus.flatMap(GameStatus.init(rawValue:)) ?? .backlog
        hoursPlayed = try container.decodeIfPresent(Int.self, forKey: .hoursPlayed)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating).flatMap(Rating.init)
        review = try container.decodeIfPresent(String.self, forKey: .review) ?? ""
        notes = try container.decodeIfPresent([GameNote].self, forKey: .notes) ?? []
        released = try container.decodeIfPresent(String.self, forKey: .released)
        playtime = try container.decodeIfPresent(Int.self, forKey: .playtime)
        platforms = try container.decodeIfPresent([String].self, forKey: .platforms) ?? []
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(coverImageUrl, forKey: .coverImageUrl)
        try container.encodeIfPresent(customCoverImagePath, forKey: .customCoverImagePath)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(hoursPlayed, forKey: .hoursPlayed)
        try container.encodeIfPresent(rating?.value, forKey: .rating)
        try container.encode(review, forKey: .review)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(released, forKey: .released)
        try container.encodeIfPresent(playtime, forKey: .playtime)
        try container.encode(platforms, forKey: .platforms)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
