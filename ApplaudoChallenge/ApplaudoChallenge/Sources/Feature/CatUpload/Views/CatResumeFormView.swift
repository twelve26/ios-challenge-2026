//
//  CatResumeFormView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatResumeFormView: View {
    @ObservedObject var viewModel: CatUploadFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            SectionHeader(
                title: LocalizableKey.CatUpload.review,
                subtitle: LocalizableKey.CatUpload.reviewSubtitle,
                systemImage: "checklist"
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                summaryRow(
                    title: LocalizableKey.CatUpload.catName,
                    value: basicInformation.trimmedName
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.breed,
                    value: basicInformation.breed?.name
                        ?? LocalizableKey.MyCatDetail.notAvailable
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.age,
                    value: basicInformation.age
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.shortDescription,
                    value: basicInformation.trimmedDescription
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.ageMonths,
                    value: optionalValue(additionalInformation.ageMonths)
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.microchipID,
                    value: optionalValue(additionalInformation.microchipID)
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.country,
                    value: optionalValue(additionalInformation.country)
                )
                summaryRow(
                    title: LocalizableKey.CatUpload.bodyConditionScore,
                    value: optionalValue(additionalInformation.bodyConditionScore)
                )
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
    }

    private var basicInformation: CatBasicInformation {
        viewModel.formData.basicInformation
    }

    private var additionalInformation: CatAdditionalInformation {
        viewModel.formData.additionalInformation
    }

    private func summaryRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(value)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func optionalValue(_ value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty
            ? LocalizableKey.MyCatDetail.notAvailable
            : trimmedValue
    }
}

#Preview {
    CatResumeFormView(viewModel: CatUploadFormViewModel())
        .padding()
}
