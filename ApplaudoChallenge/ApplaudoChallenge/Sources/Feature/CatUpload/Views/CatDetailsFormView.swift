//
//  CatDetailsFormView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

private enum CountryCatalog {
    static let names: [String] = {
        let localizedNames = Locale.Region.isoRegions.compactMap { region in
            Locale.autoupdatingCurrent.localizedString(forRegionCode: region.identifier)
        }

        return Array(Set(localizedNames)).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }()
}

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

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                AppTextField(
                    label: LocalizableKey.CatUpload.country,
                    placeholder: LocalizableKey.CatUpload.optionalPlaceholder,
                    text: detailsBinding(for: \.country),
                    icon: "globe.americas"
                )

                countrySuggestions
            }

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

    @ViewBuilder
    private var countrySuggestions: some View {
        if !matchingCountries.isEmpty {
            VStack(spacing: AppTheme.Spacing.xs) {
                ForEach(matchingCountries, id: \.self) { country in
                    Button {
                        viewModel.formData.additionalInformation.country = country
                    } label: {
                        HStack {
                            Image(systemName: "globe.americas")
                            Text(country)
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

    private var matchingCountries: [String] {
        let search = viewModel.formData.additionalInformation.country
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !search.isEmpty,
              !CountryCatalog.names.contains(where: {
                  $0.compare(
                      search,
                      options: [.caseInsensitive, .diacriticInsensitive]
                  ) == .orderedSame
              })
        else {
            return []
        }

        return Array(
            CountryCatalog.names
                .filter {
                    $0.range(
                        of: search,
                        options: [.caseInsensitive, .diacriticInsensitive]
                    ) != nil
                }
                .prefix(5)
        )
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
