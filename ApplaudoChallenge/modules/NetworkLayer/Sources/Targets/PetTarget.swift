import Moya

enum PetTarget {
    case getPets(breedID: String, pagination: Pagination)
    case deletePet(id: String)
}

extension PetTarget: NetworkingTargetType {
    var requestPath: String {
        switch self {
        case .getPets:
            return "pets"
        case .deletePet(let id):
            return "pets/\(id)"
        }
    }

    var requestMethod: RequestMethod {
        switch self {
        case .getPets:
            return .get
        case .deletePet:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .getPets(let breedID, let pagination):
            return .requestParameters(
                parameters: [
                    "breed_id": breedID,
                    "page": pagination.page,
                    "limit": pagination.limit,
                ],
                encoding: URLEncoding.queryString
            )
        case .deletePet:
            return .requestPlain
        }
    }
}
