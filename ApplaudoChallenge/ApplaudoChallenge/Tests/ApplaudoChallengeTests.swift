import Testing
import Combine
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

    @Test func formRequiresNameWithAtLeastThreeCharacters() {
        let form = CatFormData(
            basicInformation: CatBasicInformation(
                name: "Mi",
                breed: CatBreed(id: "beng", name: "Bengal"),
                age: "2",
                shortDescription: "Playful cat"
            )
        )

        #expect(!form.basicInformation.isNameValid)
        #expect(!form.isPhaseOneValid)
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

    @Test func formDoesNotAdvanceWithMissingRequiredFields() {
        let viewModel = CatUploadFormViewModel(
            storageService: LocalCatStorageSpy(),
            breedService: BreedServiceStub()
        )

        viewModel.performPrimaryAction()

        #expect(viewModel.currentStep == 0)
        #expect(viewModel.didAttemptStepOne)
    }

    @Test func formAdvancesThroughOptionalDetailsAndSaves() {
        let storage = LocalCatStorageSpy()
        let viewModel = CatUploadFormViewModel(
            storageService: storage,
            breedService: BreedServiceStub()
        )
        viewModel.formData.basicInformation = CatBasicInformation(
            name: "Milo",
            breed: CatBreed(id: "beng", name: "Bengal"),
            age: "2",
            shortDescription: "Playful cat"
        )

        viewModel.performPrimaryAction()
        #expect(viewModel.currentStep == 1)

        viewModel.performPrimaryAction()
        #expect(viewModel.currentStep == 2)

        viewModel.performPrimaryAction()
        #expect(storage.savedCats.count == 1)
        #expect(storage.savedCats.first?.name == "Milo")
        #expect(viewModel.currentStep == 0)
        #expect(viewModel.isConfirmationPresented)
    }

}

private final class LocalCatStorageSpy: LocalCatStorageServiceType {
    private(set) var savedCats: [CatProfile] = []

    func fetchCats() throws -> [CatProfile] {
        savedCats
    }

    func save(_ cat: CatProfile) throws {
        savedCats.append(cat)
    }

    func deleteCat(id: UUID) throws {
        savedCats.removeAll { $0.id == id }
    }
}

private struct BreedServiceStub: BreedServiceType {
    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        Just([])
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
