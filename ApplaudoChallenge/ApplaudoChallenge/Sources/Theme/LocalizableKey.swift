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
        static let delete = value("my_cat.detail.delete")
        static let cancel = value("my_cat.detail.cancel")
        static let deleteConfirmationTitle = value("my_cat.detail.delete_confirmation_title")
        static let deleteConfirmationMessage = value("my_cat.detail.delete_confirmation_message")
    }

    enum CatUpload {
        static let navigationTitle = value("cat_upload.navigation_title")
        static let title = value("cat_upload.title")
        static let basicInformation = value("cat_upload.basic_information")
        static let basicInformationSubtitle = value("cat_upload.basic_information_subtitle")
        static let details = value("cat_upload.details")
        static let detailsSubtitle = value("cat_upload.details_subtitle")
        static let review = value("cat_upload.review")
        static let reviewSubtitle = value("cat_upload.review_subtitle")
        static let catName = value("cat_upload.cat_name")
        static let catNamePlaceholder = value("cat_upload.cat_name_placeholder")
        static let breed = value("cat_upload.breed")
        static let breedPlaceholder = value("cat_upload.breed_placeholder")
        static let age = value("cat_upload.age")
        static let agePlaceholder = value("cat_upload.age_placeholder")
        static let shortDescription = value("cat_upload.short_description")
        static let descriptionPlaceholder = value("cat_upload.description_placeholder")
        static let ageMonths = value("cat_upload.age_months")
        static let microchipID = value("cat_upload.microchip_id")
        static let country = value("cat_upload.country")
        static let bodyConditionScore = value("cat_upload.body_condition_score")
        static let optionalPlaceholder = value("cat_upload.optional_placeholder")
        static let bodyConditionPlaceholder = value("cat_upload.body_condition_placeholder")
        static let next = value("cat_upload.next")
        static let create = value("cat_upload.create")
        static let done = value("cat_upload.done")
        static let requiredFieldsTitle = value("cat_upload.required_fields_title")
        static let requiredFieldsMessage = value("cat_upload.required_fields_message")
        static let requiredField = value("cat_upload.required_field")
        static let selectBreed = value("cat_upload.select_breed")
        static let invalidName = value("cat_upload.invalid_name")
        static let invalidAge = value("cat_upload.invalid_age")
        static let invalidAgeMonths = value("cat_upload.invalid_age_months")
        static let invalidBodyCondition = value("cat_upload.invalid_body_condition")
        static let saveError = value("cat_upload.save_error")
        static let successTitle = value("cat_upload.success_title")
        static let successMessage = value("cat_upload.success_message")
        static let stepTitles = [
            value("cat_upload.step.basic"),
            value("cat_upload.step.details"),
            value("cat_upload.step.review"),
        ]
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
