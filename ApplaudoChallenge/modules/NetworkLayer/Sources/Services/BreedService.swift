import Combine

public protocol BreedServiceType {
    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError>
}

final class BreedService: BreedServiceType {
    private let requester: NetworkingRequesterType

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    func fetchBreeds(
        pagination: Pagination
    ) -> AnyPublisher<[CatBreed], NetworkError> {
        requester.execute(
            request: BreedTarget.getBreeds(pagination: pagination)
        )
    }
}
