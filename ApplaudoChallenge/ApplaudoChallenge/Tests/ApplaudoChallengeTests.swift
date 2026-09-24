import Testing
import Foundation
import NetworkLayer
@testable import ApplaudoChallenge

struct ApplaudoChallengeTests {

    @Test func validFormBuildsLocalProfile() {
        let breed = CatBreed(id: "beng", name: "Bengal")
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "  Milo  ",
                breed: breed,
                age: "2",
                shortDescription: "  Playful cat  "
            ),
            additionalInformation: CatAdditionalInformation(
                ageMonths: "4",
                microchipID: "  chip-123  ",
                country: "  SV  ",
                bodyConditionScore: "5"
            )
        )

        let profile = form.makeProfile()
        #expect(form.isValid)
        #expect(profile?.name == "Milo")
        #expect(profile?.breed == breed)
        #expect(profile?.age == 2)
        #expect(profile?.ageMonths == 4)
        #expect(profile?.shortDescription == "Playful cat")
        #expect(profile?.microchipID == "chip-123")
        #expect(profile?.country == "SV")
        #expect(profile?.bodyConditionScore == 5)
    }

    @Test func formRequiresOnlyMinimumFields() {
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "Milo",
                breed: CatBreed(id: "beng", name: "Bengal"),
                age: "2",
                shortDescription: "Playful cat"
            )
        )

        #expect(form.isPhaseOneValid)
        #expect(form.isPhaseTwoValid)
        #expect(form.isValid)
    }

    @Test func invalidFormDoesNotCreateFinalObjects() {
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "",
                age: "0",
                shortDescription: ""
            )
        )

        #expect(!form.isPhaseOneValid)
        #expect(!form.isValid)
        #expect(form.makeProfile() == nil)
    }

    @Test func secondPhaseRejectsInvalidOptionalNumbers() {
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "Milo",
                breed: CatBreed(id: "beng", name: "Bengal"),
                age: "2",
                shortDescription: "Playful cat"
            ),
            additionalInformation: CatAdditionalInformation(
                ageMonths: "12",
                bodyConditionScore: "10"
            )
        )

        #expect(form.isPhaseOneValid)
        #expect(!form.isPhaseTwoValid)
        #expect(form.makeProfile() == nil)
    }

    @Test func localStoragePersistsAndDeletesCats() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("cats.json")
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let service = LocalCatStorageService(fileURL: fileURL)
        let cat = CatProfile(
            name: "Milo",
            breed: CatBreed(id: "beng", name: "Bengal"),
            age: 2,
            shortDescription: "Playful cat"
        )

        try service.save(cat)
        #expect(try service.fetchCats() == [cat])

        try service.deleteCat(id: cat.id)
        #expect(try service.fetchCats().isEmpty)
    }

}
