import Moya

enum BreedTarget {
    case getBreeds(pagination: Pagination)
    case getBreedDetail(id: String)
}

extension BreedTarget: NetworkingTargetType {
    var requestPath: String {
        switch self {
        case .getBreeds:
            return "breeds"
        case .getBreedDetail(let id):
            return "breeds/\(id)"
        }
    }

    var requestMethod: RequestMethod {
        .get
    }

    var task: Moya.Task {
        switch self {
        case .getBreedDetail:
            return .requestPlain
        case .getBreeds(let pagination):
            return .requestParameters(
                parameters: [
                    "page": pagination.page,
                    "limit": pagination.limit,
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
}
