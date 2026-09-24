//
//  CatDetailsFormView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatDetailsFormView: View {
    @ObservedObject var viewModel: CatUploadFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            SectionHeader(
                title: LocalizableKey.CatUpload.details,
                subtitle: LocalizableKey.CatUpload.detailsSubtitle,
                systemImage: "list.bullet.clipboard"
            )

            AppTextField(
                label: LocalizableKey.CatUpload.ageMonths,
                placeholder: LocalizableKey.CatUpload.optionalPlaceholder,
                text: detailsBinding(for: \.ageMonths),
                errorMessage: ageMonthsError,
                keyboardType: .numberPad,
                icon: "calendar.badge.clock",
                allowsOnlyNumbers: true
            )

            AppTextField(
                label: LocalizableKey.CatUpload.microchipID,
                placeholder: LocalizableKey.CatUpload.optionalPlaceholder,
                text: detailsBinding(for: \.microchipID),
                icon: "number"
            )

            AppTextField(
                label: LocalizableKey.CatUpload.country,
                placeholder: LocalizableKey.CatUpload.optionalPlaceholder,
                text: detailsBinding(for: \.country),
                icon: "globe.americas"
            )

            AppTextField(
                label: LocalizableKey.CatUpload.bodyConditionScore,
                placeholder: LocalizableKey.CatUpload.bodyConditionPlaceholder,
                text: detailsBinding(for: \.bodyConditionScore),
                errorMessage: bodyConditionError,
                keyboardType: .numberPad,
                icon: "gauge.with.dots.needle.50percent",
                allowsOnlyNumbers: true
            )
        }
    }

    private var ageMonthsError: String? {
        guard viewModel.didAttemptStepTwo,
              !viewModel.formData.additionalInformation.isAgeMonthsValid
        else {
            return nil
        }
        return LocalizableKey.CatUpload.invalidAgeMonths
    }

    private var bodyConditionError: String? {
        guard viewModel.didAttemptStepTwo,
              !viewModel.formData.additionalInformation.isBodyConditionScoreValid
        else {
            return nil
        }
        return LocalizableKey.CatUpload.invalidBodyCondition
    }

    private func detailsBinding(
        for keyPath: WritableKeyPath<CatAdditionalInformation, String>
    ) -> Binding<String> {
        Binding(
            get: { viewModel.formData.additionalInformation[keyPath: keyPath] },
            set: { viewModel.formData.additionalInformation[keyPath: keyPath] = $0 }
        )
    }
}

#Preview {
    CatDetailsFormView(viewModel: CatUploadFormViewModel())
        .padding()
}
