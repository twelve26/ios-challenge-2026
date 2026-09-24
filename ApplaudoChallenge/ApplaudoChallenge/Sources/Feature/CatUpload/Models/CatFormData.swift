import Foundation
import NetworkLayer

/// Required information collected during the first form phase.
struct CatBasicInformation: Equatable {
    var name = ""
    var breed: CatBreed?
    var age = ""
    var shortDescription = ""

    var isValid: Bool {
        !trimmedName.isEmpty
            && breed != nil
            && parsedAge.map { $0 > 0 } == true
            && !trimmedDescription.isEmpty
    }

    var parsedAge: Int? {
        Int(age.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedDescription: String {
        shortDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Optional information collected during the second form phase.
struct CatAdditionalInformation: Equatable {
    var image: CatUploadImage?
    var ageMonths = ""
    var microchipID = ""
    var country = ""
    var bodyConditionScore = ""

    var isValid: Bool {
        isOptionalIntegerValid(ageMonths, validRange: 0...11)
            && isOptionalIntegerValid(bodyConditionScore, validRange: 1...9)
    }

    var parsedAgeMonths: Int {
        Int(ageMonths.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    var parsedBodyConditionScore: Int? {
        Int(bodyConditionScore.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var trimmedMicrochipID: String? {
        nonEmptyValue(microchipID)
    }

    var trimmedCountry: String? {
        nonEmptyValue(country)
    }

    private func isOptionalIntegerValid(
        _ value: String,
        validRange: ClosedRange<Int>
    ) -> Bool {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return true }
        guard let integer = Int(trimmedValue) else { return false }
        return validRange.contains(integer)
    }

    private func nonEmptyValue(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

/// Mutable draft shared by both phases of the multi-step form.
struct CatFormData: Equatable {
    var basicInformation = CatBasicInformation()
    var additionalInformation = CatAdditionalInformation()

    var isPhaseOneValid: Bool {
        basicInformation.isValid
    }

    var isPhaseTwoValid: Bool {
        additionalInformation.isValid
    }

    var isValid: Bool {
        isPhaseOneValid && isPhaseTwoValid
    }

    func makeProfile(id: UUID = UUID()) -> CatProfile? {
        guard
            let breed = basicInformation.breed,
            let age = basicInformation.parsedAge,
            isValid
        else {
            return nil
        }

        return CatProfile(
            id: id,
            name: basicInformation.trimmedName,
            breed: breed,
            age: age,
            ageMonths: additionalInformation.parsedAgeMonths,
            shortDescription: basicInformation.trimmedDescription,
            imageData: additionalInformation.image?.data,
            microchipID: additionalInformation.trimmedMicrochipID,
            country: additionalInformation.trimmedCountry,
            bodyConditionScore: additionalInformation.parsedBodyConditionScore
        )
    }

    func makeUploadRequest() -> CatUploadRequest? {
        guard
            let breed = basicInformation.breed,
            let age = basicInformation.parsedAge,
            isValid
        else {
            return nil
        }

        return CatUploadRequest(
            name: basicInformation.trimmedName,
            breedID: breed.id,
            ageYears: age,
            ageMonths: additionalInformation.parsedAgeMonths,
            description: basicInformation.trimmedDescription,
            image: additionalInformation.image,
            microchipID: additionalInformation.trimmedMicrochipID,
            country: additionalInformation.trimmedCountry,
            bodyConditionScore: additionalInformation.parsedBodyConditionScore
        )
    }
}
