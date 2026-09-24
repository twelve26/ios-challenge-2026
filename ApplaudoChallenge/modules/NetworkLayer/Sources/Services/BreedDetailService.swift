import Combine

public protocol BreedDetailServiceType {
    func fetchBreedDetail(id: String) -> AnyPublisher<CatBreed, NetworkError>
}

final class BreedDetailService: BreedDetailServiceType {
    private let requester: NetworkingRequesterType

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    func fetchBreedDetail(id: String) -> AnyPublisher<CatBreed, NetworkError> {
        requester.execute(request: BreedTarget.getBreedDetail(id: id))
    }
}
