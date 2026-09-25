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

    @Test func numericValidationAcceptsBoundariesAndRejectsOverflow() {
        let lowerBoundary = CatAdditionalInformation(
            ageMonths: "0",
            bodyConditionScore: "1"
        )
        let upperBoundary = CatAdditionalInformation(
            ageMonths: "11",
            bodyConditionScore: "9"
        )
        let overflowingAge = CatBasicInformation(
            name: "Milo",
            breed: CatBreed(id: "beng", name: "Bengal"),
            age: String(repeating: "9", count: 100),
            shortDescription: "Playful cat"
        )

        #expect(lowerBoundary.isValid)
        #expect(upperBoundary.isValid)
        #expect(!overflowingAge.isAgeValid)
        #expect(!overflowingAge.isValid)
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

    @Test func localStorageRejectsCorruptedJSONWithoutCrashing() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("cats.json")
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL)

        let service = LocalCatStorageService(fileURL: fileURL)
        #expect(throws: DecodingError.self) {
            try service.fetchCats()
        }
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

    @Test func formSaveFailurePreservesDraftAndShowsError() {
        let storage = LocalCatStorageSpy(saveError: StorageTestError.expected)
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
        viewModel.performPrimaryAction()
        viewModel.performPrimaryAction()

        #expect(storage.savedCats.isEmpty)
        #expect(viewModel.currentStep == 2)
        #expect(viewModel.formData.basicInformation.name == "Milo")
        #expect(viewModel.errorMessage == StorageTestError.expected.localizedDescription)
        #expect(!viewModel.isConfirmationPresented)
    }

    @Test func countrySuggestionsAreBoundedAndHideExactSelection() throws {
        let country = try #require(CountryCatalog.names.first)

        #expect(CountryCatalog.names.count > 200)
        #expect(CountryCatalog.suggestions(matching: "a", limit: 3).count <= 3)
        #expect(CountryCatalog.suggestions(matching: country).isEmpty)
        #expect(CountryCatalog.suggestions(matching: " ").isEmpty)
    }

}

private enum StorageTestError: LocalizedError {
    case expected

    var errorDescription: String? {
        "Expected storage failure."
    }
}

private final class LocalCatStorageSpy: LocalCatStorageServiceType {
    private(set) var savedCats: [CatProfile] = []
    private let saveError: Error?

    init(saveError: Error? = nil) {
        self.saveError = saveError
    }

    func fetchCats() throws -> [CatProfile] {
        savedCats
    }

    func save(_ cat: CatProfile) throws {
        if let saveError {
            throw saveError
        }
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
