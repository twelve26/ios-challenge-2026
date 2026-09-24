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
}

private final class BreedServiceStub: BreedServiceType {
    private let responses: [Int: Result<[CatBreed], NetworkError>]
    private(set) var requestedPages: [Int] = []

    init(responses: [Int: Result<[CatBreed], NetworkError>]) {
        self.responses = responses
    }

    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        requestedPages.append(pagination.page)

        return responses[pagination.page, default: .success([])]
            .publisher
            .eraseToAnyPublisher()
    }
}
