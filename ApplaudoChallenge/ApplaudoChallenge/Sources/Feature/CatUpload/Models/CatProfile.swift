import Foundation
import NetworkLayer

/// Validated cat data used for presentation and local persistence.
struct CatProfile: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let breed: CatBreed
    let age: Int
    let ageMonths: Int
    let shortDescription: String
    let imageData: Data?
    let microchipID: String?
    let country: String?
    let bodyConditionScore: Int?

    init(
        id: UUID = UUID(),
        name: String,
        breed: CatBreed,
        age: Int,
        ageMonths: Int = 0,
        shortDescription: String,
        imageData: Data? = nil,
        microchipID: String? = nil,
        country: String? = nil,
        bodyConditionScore: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.ageMonths = ageMonths
        self.shortDescription = shortDescription
        self.imageData = imageData
        self.microchipID = microchipID
        self.country = country
        self.bodyConditionScore = bodyConditionScore
    }
}
