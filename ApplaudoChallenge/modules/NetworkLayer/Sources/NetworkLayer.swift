import Moya

/// Public composition root for every API service exposed by this module.
public final class NetworkLayer {
    public let breedService: BreedServiceType
    public let breedDetailService: BreedDetailServiceType

    /// Creates a network layer configured for live API requests.
    public convenience init() {
        self.init(
            requester: NetworkingRequester(
                provider: MoyaProvider<MultiTarget>.networkingProvider()
            )
        )
    }

    /// Internal dependency-injection point used by the module's tests.
    init(requester: NetworkingRequesterType) {
        breedService = BreedService(requester: requester)
        breedDetailService = BreedDetailService(requester: requester)
    }
}
