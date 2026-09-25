import Combine
import Foundation
import Moya
import XCTest
@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testBreedServiceSendsPaginationParameters() {
        let requester = RequesterSpy(
            result: .success(Data(#"[{"id":"beng","name":"Bengal"}]"#.utf8))
        )
        let service = NetworkLayer(requester: requester).breedService
        let expectation = expectation(description: "Receives breeds")

        service.fetchBreeds(pagination: Pagination(page: 2, limit: 10))
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but received \(error)")
                }
            },
            receiveValue: { breeds in
                XCTAssertEqual(breeds, [CatBreed(id: "beng", name: "Bengal")])
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

        guard let request = requester.requests.first else {
            return XCTFail("Expected a captured request")
        }
        XCTAssertEqual(request.requestPath, "breeds")

        guard case .requestParameters(let parameters, _) = request.task else {
            return XCTFail("Expected query parameters")
        }
        XCTAssertNil(parameters["breed_groups"])
        XCTAssertEqual(parameters["page"] as? Int, 2)
        XCTAssertEqual(parameters["limit"] as? Int, 10)
        XCTAssertEqual(parameters["order"] as? String, "ASC")
    }

    func testBreedDetailServiceRequestsBreedByID() {
        let requester = RequesterSpy(
            result: .success(
                Data(
                    #"""
                    {
                      "id": "abys",
                      "name": "Abyssinian",
                      "life_span": "14-17",
                      "temperament": "Active, Intelligent, Playful",
                      "origin": "Egypt",
                      "description": "An active and curious cat.",
                      "image": {
                        "id": "KWdLHmOqc",
                        "url": "https://cdn2.thecatapi.com/images/KWdLHmOqc.jpg",
                        "width": 3114,
                        "height": 2609
                      }
                    }
                    """#.utf8
                )
            )
        )
        let service = NetworkLayer(requester: requester).breedDetailService
        let expectation = expectation(description: "Receives breed detail")

        service.fetchBreedDetail(id: "abys")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but received \(error)")
                    }
                },
                receiveValue: { breed in
                    XCTAssertEqual(breed.id, "abys")
                    XCTAssertEqual(breed.name, "Abyssinian")
                    XCTAssertEqual(breed.lifeSpan, "14-17")
                    XCTAssertEqual(breed.temperament, "Active, Intelligent, Playful")
                    XCTAssertEqual(breed.origin, "Egypt")
                    XCTAssertEqual(breed.description, "An active and curious cat.")
                    XCTAssertEqual(
                        breed.image?.url,
                        "https://cdn2.thecatapi.com/images/KWdLHmOqc.jpg"
                    )
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(requester.requests.first?.requestPath, "breeds/abys")
    }

    func testServicePreservesServerError() {
        let responseData = Data(#"{"message":"Unauthorized"}"#.utf8)
        let requester = RequesterSpy(
            result: .failure(.serverError(statusCode: 401, data: responseData))
        )
        let service = NetworkLayer(requester: requester).breedService
        let expectation = expectation(description: "Receives server error")

        service.fetchBreeds(pagination: .init())
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(.serverError(let statusCode, let data)) = completion else {
                        return XCTFail("Expected a server error")
                    }

                    XCTAssertEqual(statusCode, 401)
                    XCTAssertEqual(data, responseData)
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected the request to fail")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testServiceMapsInvalidJSONToDecodingError() {
        let requester = RequesterSpy(result: .success(Data(#"{"unexpected":true}"#.utf8)))
        let service = NetworkLayer(requester: requester).breedDetailService
        let expectation = expectation(description: "Receives decoding error")

        service.fetchBreedDetail(id: "abys")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(.decodingFailed) = completion else {
                        return XCTFail("Expected a decoding error")
                    }

                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected decoding to fail")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testServicePreservesConnectivityError() {
        let requester = RequesterSpy(
            result: .failure(.unknown(underlying: NetworkLayerTestError.offline))
        )
        let service = NetworkLayer(requester: requester).breedService
        let expectation = expectation(description: "Receives connectivity error")

        service.fetchBreeds(pagination: .init())
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(.unknown(let underlyingError)) = completion else {
                        return XCTFail("Expected an unknown network error")
                    }

                    XCTAssertEqual(
                        underlyingError.localizedDescription,
                        NetworkLayerTestError.offline.localizedDescription
                    )
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected the request to fail")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }
}

private enum NetworkLayerTestError: LocalizedError {
    case offline

    var errorDescription: String? {
        "Expected offline failure."
    }
}

private final class RequesterSpy: NetworkingRequesterType {
    let result: Result<Data, NetworkError>
    private(set) var requests: [NetworkingTargetType] = []

    init(result: Result<Data, NetworkError>) {
        self.result = result
    }

    func execute(request: NetworkingTargetType) -> AnyPublisher<Data, NetworkError> {
        requests.append(request)
        return result.publisher.eraseToAnyPublisher()
    }
}
