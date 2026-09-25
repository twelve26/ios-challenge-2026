//
//  CatSimpleFormView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatSimpleFormView: View {
    @ObservedObject var viewModel: CatUploadFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            SectionHeader(
                title: hasValidationError
                    ? LocalizableKey.CatUpload.requiredFieldsTitle
                    : LocalizableKey.CatUpload.basicInformation,
                subtitle: hasValidationError
                    ? LocalizableKey.CatUpload.requiredFieldsMessage
                    : LocalizableKey.CatUpload.basicInformationSubtitle,
                systemImage: hasValidationError
                    ? "exclamationmark.triangle"
                    : "info.circle"
            )

            AppTextField(
                label: LocalizableKey.CatUpload.catName,
                placeholder: LocalizableKey.CatUpload.catNamePlaceholder,
                text: basicBinding(for: \.name),
                errorMessage: nameError,
                icon: "cat"
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                AppTextField(
                    label: LocalizableKey.CatUpload.breed,
                    placeholder: LocalizableKey.CatUpload.breedPlaceholder,
                    text: Binding(
                        get: { viewModel.breedName },
                        set: viewModel.updateBreedName
                    ),
                    errorMessage: breedError,
                    icon: "pawprint"
                )

                breedSuggestions
            }

            AppTextField(
                label: LocalizableKey.CatUpload.age,
                placeholder: LocalizableKey.CatUpload.agePlaceholder,
                text: basicBinding(for: \.age),
                errorMessage: ageError,
                keyboardType: .numberPad,
                icon: "calendar",
                allowsOnlyNumbers: true
            )

            AppTextField(
                label: LocalizableKey.CatUpload.shortDescription,
                placeholder: LocalizableKey.CatUpload.descriptionPlaceholder,
                text: basicBinding(for: \.shortDescription),
                errorMessage: requiredError(
                    for: viewModel.formData.basicInformation.shortDescription
                ),
                icon: "text.alignleft"
            )
        }
    }

    private var hasValidationError: Bool {
        viewModel.didAttemptStepOne && !viewModel.formData.isPhaseOneValid
    }

    @ViewBuilder
    private var breedSuggestions: some View {
        let matchingBreeds = viewModel.matchingBreeds()

        if !matchingBreeds.isEmpty {
            VStack(spacing: AppTheme.Spacing.xs) {
                ForEach(matchingBreeds, id: \.id) { breed in
                    Button {
                        viewModel.selectBreed(breed)
                    } label: {
                        HStack {
                            Image(systemName: "cat")
                            Text(breed.name)
                            Spacer()
                        }
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.surface)
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var breedError: String? {
        guard viewModel.didAttemptStepOne,
              viewModel.formData.basicInformation.breed == nil
        else {
            return nil
        }

        return viewModel.breedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? LocalizableKey.CatUpload.requiredField
            : LocalizableKey.CatUpload.selectBreed
    }

    private var ageError: String? {
        guard viewModel.didAttemptStepOne else { return nil }
        let age = viewModel.formData.basicInformation.age
        if age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return LocalizableKey.CatUpload.requiredField
        }
        return viewModel.formData.basicInformation.isAgeValid
            ? nil
            : LocalizableKey.CatUpload.invalidAge
    }

    private var nameError: String? {
        guard viewModel.didAttemptStepOne else { return nil }
        let name = viewModel.formData.basicInformation.trimmedName
        if name.isEmpty {
            return LocalizableKey.CatUpload.requiredField
        }
        return viewModel.formData.basicInformation.isNameValid
            ? nil
            : LocalizableKey.CatUpload.invalidName
    }

    private func requiredError(for value: String) -> String? {
        guard viewModel.didAttemptStepOne,
              value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        return LocalizableKey.CatUpload.requiredField
    }

    private func basicBinding(
        for keyPath: WritableKeyPath<CatBasicInformation, String>
    ) -> Binding<String> {
        Binding(
            get: { viewModel.formData.basicInformation[keyPath: keyPath] },
            set: { viewModel.formData.basicInformation[keyPath: keyPath] = $0 }
        )
    }
}

#Preview {
    CatSimpleFormView(viewModel: CatUploadFormViewModel())
        .padding()
}
