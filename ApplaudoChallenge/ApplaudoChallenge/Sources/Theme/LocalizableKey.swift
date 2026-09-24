import Foundation

enum LocalizableKey {
    enum Tab {
        static let catBreeds = value("tab.cat_breeds")
        static let myCats = value("tab.my_cats")
        static let addCat = value("tab.add_cat")
    }

    enum BreedList {
        static let navigationTitle = value("breed.list.navigation_title")
        static let loading = value("breed.list.loading")
        static let loadingMore = value("breed.list.loading_more")
        static let errorTitle = value("breed.list.error_title")
        static let emptyTitle = value("breed.list.empty_title")
        static let emptyMessage = value("breed.list.empty_message")
        static let retry = value("breed.list.retry")
        static let serverError = value("breed.list.server_error")
        static let decodingError = value("breed.list.decoding_error")
        static let connectionError = value("breed.list.connection_error")
    }

    enum BreedDetail {
        static let identifier = value("breed.detail.identifier")
        static let name = value("breed.detail.name")
        static let description = value("breed.detail.description")
        static let imageURL = value("breed.detail.image_url")
        static let origin = value("breed.detail.origin")
        static let temperament = value("breed.detail.temperament")
        static let lifeSpan = value("breed.detail.life_span")
        static let notAvailable = value("breed.detail.not_available")
        static let imageAccessibilityLabel = value("breed.detail.image_accessibility_label")
    }

    enum MyCats {
        static let navigationTitle = value("my_cats.navigation_title")
        static let placeholder = value("my_cats.placeholder")
        static let emptyTitle = value("my_cats.empty_title")
        static let addCat = value("my_cats.add_cat")
        static let errorTitle = value("my_cats.error_title")
        static let retry = value("my_cats.retry")
    }

    enum MyCatDetail {
        static let information = value("my_cat.detail.information")
        static let name = value("my_cat.detail.name")
        static let breed = value("my_cat.detail.breed")
        static let ageYears = value("my_cat.detail.age_years")
        static let ageMonths = value("my_cat.detail.age_months")
        static let description = value("my_cat.detail.description")
        static let microchipID = value("my_cat.detail.microchip_id")
        static let country = value("my_cat.detail.country")
        static let bodyConditionScore = value("my_cat.detail.body_condition_score")
        static let notAvailable = value("my_cat.detail.not_available")
    }

    enum CatUpload {
        static let navigationTitle = value("cat_upload.navigation_title")
        static let title = value("cat_upload.title")
        static let basicInformation = value("cat_upload.basic_information")
        static let details = value("cat_upload.details")
        static let review = value("cat_upload.review")
    }

    enum Preview {
        static let primaryButton = value("preview.primary_button")
        static let secondaryButton = value("preview.secondary_button")
        static let destructiveButton = value("preview.destructive_button")
        static let disabledButton = value("preview.disabled_button")
        static let loading = value("preview.loading")
        static let persianDescription = value("preview.persian_description")
        static let siameseDescription = value("preview.siamese_description")
        static let noArrow = value("preview.no_arrow")
        static let noArrowDescription = value("preview.no_arrow_description")
        static let breedName = value("preview.breed_name")
        static let enterBreedName = value("preview.enter_breed_name")
        static let email = value("preview.email")
        static let enterEmail = value("preview.enter_email")
        static let invalidEmail = value("preview.invalid_email")
        static let noCatsTitle = value("preview.no_cats_title")
        static let noCatsMessage = value("preview.no_cats_message")
        static let addCat = value("preview.add_cat")
        static let breedInformation = value("preview.breed_information")
        static let basicDetails = value("preview.basic_details")
        static let appearance = value("preview.appearance")
        static let stepTitles = [
            value("preview.step.basic_info"),
            value("preview.step.details"),
            value("preview.step.review"),
        ]
    }

    private static func value(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: .main, comment: "")
    }
}
