import Foundation
import Moya

enum CatUploadTarget {
    case create(CatUploadRequest)
}

extension CatUploadTarget: NetworkingTargetType {
    var requestPath: String {
        switch self {
        case .create:
            return "pets"
        }
    }

    var requestMethod: RequestMethod {
        .post
    }

    var task: Moya.Task {
        switch self {
        case .create(let request):
            return .uploadMultipart(request.multipartData)
        }
    }
}

private extension CatUploadRequest {
    var multipartData: [Moya.MultipartFormData] {
        var parts = [
            textPart(name, name: "name"),
            textPart(breedID, name: "breed_id"),
            textPart("1", name: "species_id"),
            textPart(description, name: "description"),
            textPart(String(ageYears), name: "age_years"),
            textPart(String(ageMonths), name: "age_months"),
        ]
        if let image {
            parts.append(imagePart(image))
        }
        if let microchipID {
            parts.append(textPart(microchipID, name: "microchip_id"))
        }
        if let country {
            parts.append(textPart(country, name: "country"))
        }
        if let bodyConditionScore {
            parts.append(textPart(String(bodyConditionScore), name: "body_condition_score"))
        }
        return parts
    }
}

private func textPart(_ value: String, name: String) -> Moya.MultipartFormData {
    Moya.MultipartFormData(provider: .data(Data(value.utf8)), name: name)
}

private func imagePart(_ image: CatUploadImage) -> Moya.MultipartFormData {
    Moya.MultipartFormData(
        provider: .data(image.data),
        name: "images",
        fileName: image.fileName,
        mimeType: image.mimeType
    )
}
