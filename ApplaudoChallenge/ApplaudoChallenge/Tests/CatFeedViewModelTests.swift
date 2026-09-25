import Combine
import NetworkLayer
import XCTest
@testable import ApplaudoChallenge

final class CatFeedViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadsAndAppendsNextPageWhenApproachingEnd() {
        let firstPage = [
            CatBreed(id: "abys", name: "Abyssinian"),
            CatBreed(id: "beng", name: "Bengal"),
        ]
        let secondPage = [
            CatBreed(id: "mcoo", name: "Maine Coon"),
        ]
        let service = BreedServiceStub(responses: [
            0: .success(firstPage),
            1: .success(secondPage),
        ])
        let viewModel = CatFeedViewModel(
            breedService: service,
            pageSize: 2,
            prefetchThreshold: 1
        )
        let initialPageLoaded = expectation(description: "Initial page loaded")
        let nextPageLoaded = expectation(description: "Next page appended")

        viewModel.$breeds
            .dropFirst()
            .sink { breeds in
                if breeds.count == 2 {
                    initialPageLoaded.fulfill()
                } else if breeds.count == 3 {
                    nextPageLoaded.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [initialPageLoaded], timeout: 1)

        viewModel.loadMoreIfNeeded(currentIndex: 1)
        wait(for: [nextPageLoaded], timeout: 1)

        XCTAssertEqual(viewModel.breeds, firstPage + secondPage)
        XCTAssertEqual(service.requestedPages, [0, 1])
        XCTAssertFalse(viewModel.canLoadMore)

        viewModel.loadMoreIfNeeded(currentIndex: 2)
        XCTAssertEqual(service.requestedPages, [0, 1])
    }

    func testInitialFailurePublishesErrorAndStopsLoading() {
        let service = BreedServiceStub(responses: [
            0: .failure(.unknown(underlying: BreedServiceTestError.expected)),
        ])
        let viewModel = CatFeedViewModel(breedService: service)
        let failureReceived = expectation(description: "Initial failure received")

        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { _ in failureReceived.fulfill() }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [failureReceived], timeout: 1)

        XCTAssertTrue(viewModel.breeds.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.paginationErrorMessage)
        XCTAssertEqual(service.requestedPages, [0])
    }

    func testPaginationFailureCanRetryTheSamePage() {
        let firstPage = [
            CatBreed(id: "abys", name: "Abyssinian"),
            CatBreed(id: "beng", name: "Bengal"),
        ]
        let secondPage = [
            CatBreed(id: "mcoo", name: "Maine Coon"),
        ]
        let service = BreedServiceStub(queuedResponses: [
            0: [.success(firstPage)],
            1: [
                .failure(.unknown(underlying: BreedServiceTestError.expected)),
                .success(secondPage),
            ],
        ])
        let viewModel = CatFeedViewModel(
            breedService: service,
            pageSize: 2,
            prefetchThreshold: 1
        )
        let initialPageLoaded = expectation(description: "Initial page loaded")
        let paginationFailureReceived = expectation(description: "Pagination failure received")
        let retryLoaded = expectation(description: "Retry loaded")

        viewModel.$breeds
            .sink { breeds in
                if breeds.count == 2 {
                    initialPageLoaded.fulfill()
                } else if breeds.count == 3 {
                    retryLoaded.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.$paginationErrorMessage
            .compactMap { $0 }
            .sink { _ in paginationFailureReceived.fulfill() }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [initialPageLoaded], timeout: 1)
        viewModel.loadMoreIfNeeded(currentIndex: 1)
        wait(for: [paginationFailureReceived], timeout: 1)

        XCTAssertEqual(viewModel.breeds, firstPage)
        XCTAssertFalse(viewModel.isLoadingNextPage)

        viewModel.retryLoadingNextPage()
        wait(for: [retryLoaded], timeout: 1)

        XCTAssertEqual(viewModel.breeds, firstPage + secondPage)
        XCTAssertNil(viewModel.paginationErrorMessage)
        XCTAssertEqual(service.requestedPages, [0, 1, 1])
    }

    func testDoesNotStartDuplicatePaginationRequestsWhileOneIsInFlight() {
        let firstPage = [
            CatBreed(id: "abys", name: "Abyssinian"),
            CatBreed(id: "beng", name: "Bengal"),
        ]
        let service = ControlledBreedServiceStub(firstPage: firstPage)
        let viewModel = CatFeedViewModel(
            breedService: service,
            pageSize: 2,
            prefetchThreshold: 1
        )
        let initialPageLoaded = expectation(description: "Initial page loaded")
        let nextPageLoaded = expectation(description: "Next page loaded")

        viewModel.$breeds
            .sink { breeds in
                if breeds.count == 2 {
                    initialPageLoaded.fulfill()
                } else if breeds.count == 3 {
                    nextPageLoaded.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [initialPageLoaded], timeout: 1)

        viewModel.loadMoreIfNeeded(currentIndex: 1)
        viewModel.loadMoreIfNeeded(currentIndex: 1)
        viewModel.retryLoadingNextPage()

        XCTAssertEqual(service.requestedPages, [0, 1])
        XCTAssertTrue(viewModel.isLoadingNextPage)

        service.completeNextPage(with: [CatBreed(id: "mcoo", name: "Maine Coon")])
        wait(for: [nextPageLoaded], timeout: 1)
        XCTAssertFalse(viewModel.isLoadingNextPage)
    }

    func testInvalidVisibleIndexDoesNotRequestAnotherPage() {
        let firstPage = [
            CatBreed(id: "abys", name: "Abyssinian"),
            CatBreed(id: "beng", name: "Bengal"),
        ]
        let service = BreedServiceStub(responses: [0: .success(firstPage)])
        let viewModel = CatFeedViewModel(
            breedService: service,
            pageSize: 2,
            prefetchThreshold: 1
        )
        let initialPageLoaded = expectation(description: "Initial page loaded")

        viewModel.$breeds
            .filter { $0.count == 2 }
            .sink { _ in initialPageLoaded.fulfill() }
            .store(in: &cancellables)

        viewModel.fetchBreeds()
        wait(for: [initialPageLoaded], timeout: 1)
        viewModel.loadMoreIfNeeded(currentIndex: -1)
        viewModel.loadMoreIfNeeded(currentIndex: 99)

        XCTAssertEqual(service.requestedPages, [0])
    }
}

private final class BreedServiceStub: BreedServiceType {
    private var queuedResponses: [Int: [Result<[CatBreed], NetworkError>]]
    private(set) var requestedPages: [Int] = []

    init(responses: [Int: Result<[CatBreed], NetworkError>]) {
        queuedResponses = responses.mapValues { [$0] }
    }

    init(queuedResponses: [Int: [Result<[CatBreed], NetworkError>]]) {
        self.queuedResponses = queuedResponses
    }

    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        requestedPages.append(pagination.page)

        guard var responses = queuedResponses[pagination.page], !responses.isEmpty else {
            return Just([])
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        let response = responses.removeFirst()
        queuedResponses[pagination.page] = responses

        return response
            .publisher
            .eraseToAnyPublisher()
    }
}

private final class ControlledBreedServiceStub: BreedServiceType {
    private let firstPage: [CatBreed]
    private let nextPageSubject = PassthroughSubject<[CatBreed], NetworkError>()
    private(set) var requestedPages: [Int] = []

    init(firstPage: [CatBreed]) {
        self.firstPage = firstPage
    }

    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        requestedPages.append(pagination.page)

        if pagination.page == 0 {
            return Just(firstPage)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        return nextPageSubject.eraseToAnyPublisher()
    }

    func completeNextPage(with breeds: [CatBreed]) {
        nextPageSubject.send(breeds)
        nextPageSubject.send(completion: .finished)
    }
}

private enum BreedServiceTestError: Error {
    case expected
}
