/// Raw values match the Android app and the Firestore schema exactly.
nonisolated enum Platform: String, Codable, CaseIterable, Sendable {
    case playstation = "PLAYSTATION"
    case xbox = "XBOX"
    case nintendo = "NINTENDO"
    case pc = "PC"
    case handheld = "HANDHELD"

    var label: String {
        switch self {
        case .playstation: "PlayStation"
        case .xbox: "Xbox"
        case .nintendo: "Nintendo"
        case .pc: "PC"
        case .handheld: "PC Handheld"
        }
    }
}

nonisolated struct Profile: Hashable, Sendable {
    var displayName = ""
    var bio = ""
    /// File name inside the managed profile image directory, never an absolute path.
    var profileImagePath: String?
    var favoritePlatforms: [Platform] = []
    var favoriteGameIds: [String] = []
}

extension Profile: Codable {
    private enum CodingKeys: String, CodingKey {
        case displayName, bio, profileImagePath, favoritePlatforms, favoriteGameIds
    }

    /// Unknown platforms are dropped instead of failing the whole profile.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        let storedPlatforms = try container.decodeIfPresent([String].self, forKey: .favoritePlatforms) ?? []
        var platforms: [Platform] = []
        for platform in storedPlatforms.compactMap(Platform.init(rawValue:)) where !platforms.contains(platform) {
            platforms.append(platform)
        }
        favoritePlatforms = platforms
        favoriteGameIds = try container.decodeIfPresent([String].self, forKey: .favoriteGameIds) ?? []
    }
}
