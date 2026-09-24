import Combine

public protocol PetServiceType {
    func fetchPets(
        breedID: String,
        pagination: Pagination
    ) -> AnyPublisher<[UploadedCat], NetworkError>

    func deletePet(id: String) -> AnyPublisher<Void, NetworkError>
}

final class PetService: PetServiceType {
    private let requester: NetworkingRequesterType

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    func fetchPets(
        breedID: String,
        pagination: Pagination
    ) -> AnyPublisher<[UploadedCat], NetworkError> {
        requester.execute(
            request: PetTarget.getPets(
                breedID: breedID,
                pagination: pagination
            )
        )
    }

    func deletePet(id: String) -> AnyPublisher<Void, NetworkError> {
        requester.execute(request: PetTarget.deletePet(id: id))
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
