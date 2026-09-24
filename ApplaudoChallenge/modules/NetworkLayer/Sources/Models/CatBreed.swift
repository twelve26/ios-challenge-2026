import Foundation

/// Breed information required by the breed list and detail screens.
public struct CatBreed: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let image: CatBreedImage?
    public let origin: String?
    public let temperament: String?
    public let lifeSpan: String?

    public init(
        id: String,
        name: String,
        description: String? = nil,
        image: CatBreedImage? = nil,
        origin: String? = nil,
        temperament: String? = nil,
        lifeSpan: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.origin = origin
        self.temperament = temperament
        self.lifeSpan = lifeSpan
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case image
        case origin
        case temperament
        case lifeSpan = "life_span"
    }
}

public struct CatBreedImage: Codable, Equatable, Hashable, Sendable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}
