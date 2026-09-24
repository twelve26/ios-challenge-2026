import Testing
import Foundation
import NetworkLayer
@testable import ApplaudoChallenge

struct ApplaudoChallengeTests {

    @Test func validFormBuildsProfileAndUploadRequest() {
        let breed = CatBreed(id: "beng", name: "Bengal")
        let image = CatUploadImage(
            data: Data([0x01]),
            fileName: "milo.jpg",
            mimeType: "image/jpeg"
        )
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "  Milo  ",
                breed: breed,
                age: "2",
                shortDescription: "  Playful cat  "
            ),
            additionalInformation: CatAdditionalInformation(
                image: image,
                ageMonths: "4",
                microchipID: "  chip-123  ",
                country: "  SV  ",
                bodyConditionScore: "5"
            )
        )

        let profile = form.makeProfile()
        let request = form.makeUploadRequest()

        #expect(form.isValid)
        #expect(profile?.name == "Milo")
        #expect(profile?.breed == breed)
        #expect(profile?.age == 2)
        #expect(profile?.ageMonths == 4)
        #expect(profile?.shortDescription == "Playful cat")
        #expect(profile?.imageData == image.data)
        #expect(profile?.microchipID == "chip-123")
        #expect(profile?.country == "SV")
        #expect(profile?.bodyConditionScore == 5)
        #expect(request?.breedID == "beng")
        #expect(request?.image == image)
        #expect(request?.microchipID == "chip-123")
        #expect(request?.country == "SV")
        #expect(request?.bodyConditionScore == 5)
    }

    @Test func formRequiresMinimumFieldsButNotImage() {
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
        #expect(form.makeProfile()?.imageData == nil)
        #expect(form.makeUploadRequest()?.image == nil)
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
        #expect(form.makeUploadRequest() == nil)
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
        #expect(form.makeUploadRequest() == nil)
    }

}
