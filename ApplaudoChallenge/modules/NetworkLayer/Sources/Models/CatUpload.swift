import Foundation

public struct CatUploadImage: Equatable, Sendable {
    public let data: Data
    public let fileName: String
    public let mimeType: String

    public init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public struct CatUploadRequest: Equatable, Sendable {
    public let name: String
    public let breedID: String
    public let ageYears: Int
    public let ageMonths: Int
    public let description: String
    public let image: CatUploadImage?
    public let microchipID: String?
    public let country: String?
    public let bodyConditionScore: Int?

    public init(
        name: String,
        breedID: String,
        ageYears: Int,
        ageMonths: Int = 0,
        description: String,
        image: CatUploadImage? = nil,
        microchipID: String? = nil,
        country: String? = nil,
        bodyConditionScore: Int? = nil
    ) {
        self.name = name
        self.breedID = breedID
        self.ageYears = ageYears
        self.ageMonths = ageMonths
        self.description = description
        self.image = image
        self.microchipID = microchipID
        self.country = country
        self.bodyConditionScore = bodyConditionScore
    }
}

public struct UploadedCat: Decodable, Equatable, Sendable {
    public let id: String
    public let name: String?
    public let breedID: String?
    public let speciesID: String?
    public let description: String?
    public let ageYears: Int?
    public let ageMonths: Int?
    public let microchipID: String?
    public let country: String?
    public let bodyConditionScore: Int?
    public let image: UploadedCatImage?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case breedID = "breed_id"
        case speciesID = "species_id"
        case description
        case ageYears = "age_years"
        case ageMonths = "age_months"
        case microchipID = "microchip_id"
        case country
        case bodyConditionScore = "body_condition_score"
        case images
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        breedID = try container.decodeIfPresent(String.self, forKey: .breedID)
        speciesID = try container.decodeIfPresent(String.self, forKey: .speciesID)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        ageYears = try container.decodeIfPresent(Int.self, forKey: .ageYears)
        ageMonths = try container.decodeIfPresent(Int.self, forKey: .ageMonths)
        microchipID = try container.decodeIfPresent(String.self, forKey: .microchipID)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        bodyConditionScore = try container.decodeIfPresent(Int.self, forKey: .bodyConditionScore)
        image = try container.decodeIfPresent([UploadedCatImage].self, forKey: .images)?.first
    }
}

public struct UploadedCatImage: Decodable, Equatable, Sendable {
    public let id: String?
    public let petID: String?
    public let url: URL?

    private enum CodingKeys: String, CodingKey {
        case id
        case petID = "pet_id"
        case url
    }
}
