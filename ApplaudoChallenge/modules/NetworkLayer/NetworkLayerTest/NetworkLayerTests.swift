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

    func testCatUploadServiceCreatesCatWithMultipartForm() {
        let requester = RequesterSpy(
            result: .success(
                Data(#"{"id":"pet-1","name":"Milo","breed_id":"beng","images":[]}"#.utf8)
            )
        )
        let service = NetworkLayer(requester: requester).catUploadService
        let image = CatUploadImage(
            data: Data([0x01, 0x02]),
            fileName: "milo.jpg",
            mimeType: "image/jpeg"
        )
        let request = CatUploadRequest(
            name: "Milo",
            breedID: "beng",
            ageYears: 2,
            ageMonths: 4,
            description: "Playful cat",
            image: image,
            microchipID: "chip-123",
            country: "SV",
            bodyConditionScore: 5
        )
        let expectation = expectation(description: "Creates a cat")

        service.createCat(request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but received \(error)")
                    }
                },
                receiveValue: { cat in
                    XCTAssertEqual(cat.id, "pet-1")
                    XCTAssertEqual(cat.name, "Milo")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

        guard let target = requester.requests.first else {
            return XCTFail("Expected a captured request")
        }
        XCTAssertEqual(target.requestPath, "pets")
        XCTAssertEqual(target.requestMethod, .post)

        guard case .uploadMultipart(let parts) = target.task else {
            return XCTFail("Expected multipart data")
        }
        XCTAssertEqual(
            Set(parts.map(\.name)),
            Set([
                "name",
                "breed_id",
                "species_id",
                "description",
                "age_years",
                "age_months",
                "images",
                "microchip_id",
                "country",
                "body_condition_score",
            ])
        )
        XCTAssertEqual(parts.first(where: { $0.name == "images" })?.fileName, "milo.jpg")
    }

    func testPetServiceFiltersPetsByBreedAndSendsPagination() {
        let requester = RequesterSpy(
            result: .success(
                Data(
                    #"""
                    [
                      {
                        "id": "pet-1",
                        "name": "Milo",
                        "breed_id": "beng",
                        "species_id": "1",
                        "description": "Playful cat",
                        "age_years": 2,
                        "age_months": 4,
                        "microchip_id": "chip-123",
                        "country": "SV",
                        "body_condition_score": 5,
                        "images": [
                          {
                            "id": "image-1",
                            "pet_id": "pet-1",
                            "url": "https://cdn2.thecatapi.com/images/image-1.jpg"
                          }
                        ]
                      }
                    ]
                    """#.utf8
                )
            )
        )
        let service = NetworkLayer(requester: requester).petService
        let expectation = expectation(description: "Receives pets for a breed")

        service.fetchPets(
            breedID: "beng",
            pagination: Pagination(page: 1, limit: 10)
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but received \(error)")
                }
            },
            receiveValue: { pets in
                XCTAssertEqual(pets.count, 1)
                XCTAssertEqual(pets.first?.name, "Milo")
                XCTAssertEqual(pets.first?.breedID, "beng")
                XCTAssertEqual(pets.first?.ageYears, 2)
                XCTAssertEqual(pets.first?.image?.id, "image-1")
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

        guard let request = requester.requests.first else {
            return XCTFail("Expected a captured request")
        }
        XCTAssertEqual(request.requestPath, "pets")
        XCTAssertEqual(request.requestMethod, .get)

        guard case .requestParameters(let parameters, _) = request.task else {
            return XCTFail("Expected query parameters")
        }
        XCTAssertEqual(parameters["breed_id"] as? String, "beng")
        XCTAssertEqual(parameters["page"] as? Int, 1)
        XCTAssertEqual(parameters["limit"] as? Int, 10)
    }

    func testPetServiceDeletesPetByID() {
        let requester = RequesterSpy(result: .success(Data()))
        let service = NetworkLayer(requester: requester).petService
        let expectation = expectation(description: "Deletes a pet")

        service.deletePet(id: "pet-1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but received \(error)")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(requester.requests.first?.requestPath, "pets/pet-1")
        XCTAssertEqual(requester.requests.first?.requestMethod, .delete)
        guard case .requestPlain = requester.requests.first?.task else {
            return XCTFail("Expected a request without a body")
        }
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
