import Combine

public protocol CatUploadServiceType {
    func createCat(_ request: CatUploadRequest) -> AnyPublisher<UploadedCat, NetworkError>
}

final class CatUploadService: CatUploadServiceType {
    private let requester: NetworkingRequesterType

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    func createCat(_ request: CatUploadRequest) -> AnyPublisher<UploadedCat, NetworkError> {
        requester.execute(request: CatUploadTarget.create(request))
    }
}
