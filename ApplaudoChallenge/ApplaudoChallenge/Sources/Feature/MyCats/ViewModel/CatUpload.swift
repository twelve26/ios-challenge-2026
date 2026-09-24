import Foundation

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
    }
}
