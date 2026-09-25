import Combine
import Foundation
import NetworkLayer
import XCTest
@testable import ApplaudoChallenge

final class CatUploadFormViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchBreedsSortsResultsForAutocomplete() {
        let service = UploadBreedServiceStub(result: .success([
            CatBreed(id: "siam", name: "Siamese"),
            CatBreed(id: "beng", name: "Bengal"),
            CatBreed(id: "bali", name: "Balinese"),
        ]))
        let viewModel = makeViewModel(breedService: service)
        let breedsLoaded = expectation(description: "Breeds loaded")

        viewModel.$breeds
            .filter { $0.count == 3 }
            .sink { _ in breedsLoaded.fulfill() }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [breedsLoaded], timeout: 1)

        XCTAssertEqual(viewModel.breeds.map(\.name), ["Balinese", "Bengal", "Siamese"])
        XCTAssertFalse(viewModel.isLoadingBreeds)
        XCTAssertNil(viewModel.breedErrorMessage)
        XCTAssertEqual(service.requestCount, 1)
    }

    func testTypingFiltersSuggestionsAndSelectingOneCompletesBreed() {
        let service = UploadBreedServiceStub(result: .success([
            CatBreed(id: "bali", name: "Balinese"),
            CatBreed(id: "beng", name: "Bengal"),
            CatBreed(id: "siam", name: "Siamese"),
        ]))
        let viewModel = makeViewModel(breedService: service)
        let breedsLoaded = expectation(description: "Breeds loaded")

        viewModel.$breeds
            .filter { !$0.isEmpty }
            .sink { _ in breedsLoaded.fulfill() }
            .store(in: &cancellables)
        viewModel.fetchBreeds()
        wait(for: [breedsLoaded], timeout: 1)

        viewModel.updateBreedName("bal")

        XCTAssertEqual(viewModel.matchingBreeds().map(\.name), ["Balinese"])
        XCTAssertNil(viewModel.formData.basicInformation.breed)

        guard let suggestion = viewModel.matchingBreeds().first else {
            return XCTFail("Expected a breed suggestion")
        }
        viewModel.selectBreed(suggestion)

        XCTAssertEqual(viewModel.formData.basicInformation.breed, suggestion)
        XCTAssertEqual(viewModel.breedName, "Balinese")
        XCTAssertTrue(viewModel.matchingBreeds().isEmpty)
    }

    func testBreedSuggestionsAreCaseInsensitiveAndRespectLimit() {
        let service = UploadBreedServiceStub(result: .success([
            CatBreed(id: "bali", name: "Balinese"),
            CatBreed(id: "bamb", name: "Bambino"),
            CatBreed(id: "beng", name: "Bengal"),
        ]))
        let viewModel = makeViewModel(breedService: service)
        let breedsLoaded = expectation(description: "Breeds loaded")

        viewModel.$breeds
            .filter { $0.count == 3 }
            .sink { _ in breedsLoaded.fulfill() }
            .store(in: &cancellables)
        viewModel.fetchBreeds()
        wait(for: [breedsLoaded], timeout: 1)

        viewModel.updateBreedName("B")

        XCTAssertEqual(viewModel.matchingBreeds(limit: 2).count, 2)
        XCTAssertTrue(viewModel.matchingBreeds(limit: 0).isEmpty)
    }

    func testBreedFailurePublishesErrorAndAllowsRetry() {
        let service = UploadBreedServiceStub(queuedResults: [
            .failure(.unknown(underlying: UploadBreedTestError.expected)),
            .success([CatBreed(id: "beng", name: "Bengal")]),
        ])
        let viewModel = makeViewModel(breedService: service)
        let failureReceived = expectation(description: "Failure received")
        let retryLoaded = expectation(description: "Retry loaded")

        viewModel.$breedErrorMessage
            .compactMap { $0 }
            .sink { _ in failureReceived.fulfill() }
            .store(in: &cancellables)
        viewModel.$breeds
            .filter { $0.count == 1 }
            .sink { _ in retryLoaded.fulfill() }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [failureReceived], timeout: 1)

        XCTAssertFalse(viewModel.isLoadingBreeds)
        XCTAssertTrue(viewModel.breeds.isEmpty)

        viewModel.fetchBreeds()
        wait(for: [retryLoaded], timeout: 1)

        XCTAssertEqual(viewModel.breeds.map(\.name), ["Bengal"])
        XCTAssertNil(viewModel.breedErrorMessage)
        XCTAssertEqual(service.requestCount, 2)
    }

    private func makeViewModel(
        breedService: BreedServiceType
    ) -> CatUploadFormViewModel {
        CatUploadFormViewModel(
            storageService: UploadStorageStub(),
            breedService: breedService
        )
    }
}

private final class UploadBreedServiceStub: BreedServiceType {
    private var queuedResults: [Result<[CatBreed], NetworkError>]
    private(set) var requestCount = 0

    init(result: Result<[CatBreed], NetworkError>) {
        queuedResults = [result]
    }

    init(queuedResults: [Result<[CatBreed], NetworkError>]) {
        self.queuedResults = queuedResults
    }

    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        requestCount += 1
        let result = queuedResults.isEmpty ? .success([]) : queuedResults.removeFirst()
        return result.publisher.eraseToAnyPublisher()
    }
}

private final class UploadStorageStub: LocalCatStorageServiceType {
    func fetchCats() throws -> [CatProfile] { [] }
    func save(_ cat: CatProfile) throws {}
    func deleteCat(id: UUID) throws {}
}

private enum UploadBreedTestError: LocalizedError {
    case expected

    var errorDescription: String? {
        "Expected breed service failure."
    }
}
