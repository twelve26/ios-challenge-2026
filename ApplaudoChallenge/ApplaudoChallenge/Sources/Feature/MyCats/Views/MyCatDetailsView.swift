//
//  MyCatDetailsView.swift
//  ApplaudoChallenge
//

import SwiftUI

struct MyCatDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDeleteConfirmationPresented = false

    let cat: CatProfile
    var onDelete: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                SectionHeader(
                    title: LocalizableKey.MyCatDetail.information,
                    systemImage: "cat.fill"
                )

                MyCatDetailsInfoView(cat: cat)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(cat.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    isDeleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(LocalizableKey.MyCatDetail.delete)
            }
        }
        .confirmationDialog(
            LocalizableKey.MyCatDetail.deleteConfirmationTitle,
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(LocalizableKey.MyCatDetail.delete, role: .destructive) {
                onDelete()
                dismiss()
            }
            Button(LocalizableKey.MyCatDetail.cancel, role: .cancel) {}
        } message: {
            Text(LocalizableKey.MyCatDetail.deleteConfirmationMessage)
        }
    }
}

private struct MyCatDetailsInfoView: View {
    let cat: CatProfile

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            infoRow(title: LocalizableKey.MyCatDetail.name, value: cat.name)
            infoRow(title: LocalizableKey.MyCatDetail.breed, value: cat.breed.name)
            infoRow(
                title: LocalizableKey.MyCatDetail.ageYears,
                value: String(cat.age)
            )
            infoRow(
                title: LocalizableKey.MyCatDetail.ageMonths,
                value: String(cat.ageMonths)
            )
            infoRow(
                title: LocalizableKey.MyCatDetail.description,
                value: cat.shortDescription
            )
            infoRow(
                title: LocalizableKey.MyCatDetail.microchipID,
                value: displayValue(cat.microchipID)
            )
            infoRow(
                title: LocalizableKey.MyCatDetail.country,
                value: displayValue(cat.country)
            )
            infoRow(
                title: LocalizableKey.MyCatDetail.bodyConditionScore,
                value: cat.bodyConditionScore.map(String.init)
                    ?? LocalizableKey.MyCatDetail.notAvailable
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(value)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func displayValue(_ value: String?) -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty
        else {
            return LocalizableKey.MyCatDetail.notAvailable
        }

        return value
    }
}

#Preview {
    NavigationStack {
        MyCatDetailsView(
            cat: CatProfile(
                name: "Milo",
                breed: .init(id: "beng", name: "Bengal"),
                age: 2,
                ageMonths: 4,
                shortDescription: "Playful and affectionate cat.",
                microchipID: "CHIP-123",
                country: "El Salvador",
                bodyConditionScore: 5
            )
        )
    }
}
