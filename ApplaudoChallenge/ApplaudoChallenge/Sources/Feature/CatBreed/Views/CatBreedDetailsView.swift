//
//  CatBreedDetailsView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import Foundation
import NetworkLayer
import SwiftUI

private enum Constants {
    static var imageHeight: CGFloat = 240.0
}

struct CatBreedDetailsView: View {
    let catBreedInfo: CatBreed

    var body: some View {
        CatBreedDetailsComponentView(catBreedInfo: catBreedInfo)
            .navigationTitle(catBreedInfo.name)
    }
}

struct CatBreedDetailsComponentView: View {
    let catBreedInfo: CatBreed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                CatBreedDetailsHeaderView(imageURL: catBreedInfo.image?.url)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    SectionHeader(
                        title: LocalizableKey.Preview.breedInformation,
                        systemImage: "cat"
                    )

                    CatBreedDetailsInfoView(breed: catBreedInfo)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .containerRelativeFrame(.horizontal)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background)
    }
}

struct CatBreedDetailsHeaderView: View {
    let imageURL: String?
    private let imageHeight: CGFloat = Constants.imageHeight

    var body: some View {
        RemoteImageView(urlString: imageURL) {
            fallbackImage
        }
        .frame(maxWidth: .infinity)
        .frame(height: imageHeight)
        .background(AppTheme.Colors.surface)
        .clipped()
        .accessibilityLabel(LocalizableKey.BreedDetail.imageAccessibilityLabel)
    }

    private var fallbackImage: some View {
        Image(systemName: "cat.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(AppTheme.Colors.primary)
            .padding(AppTheme.Spacing.xl)
    }
}

struct CatBreedDetailsInfoView: View {
    let breed: CatBreed

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            infoRow(
                title: LocalizableKey.BreedDetail.identifier,
                value: breed.id
            )
            infoRow(
                title: LocalizableKey.BreedDetail.name,
                value: breed.name
            )
            infoRow(
                title: LocalizableKey.BreedDetail.description,
                value: displayValue(breed.description)
            )
            infoRow(
                title: LocalizableKey.BreedDetail.origin,
                value: displayValue(breed.origin)
            )
            infoRow(
                title: LocalizableKey.BreedDetail.temperament,
                value: displayValue(breed.temperament)
            )
            infoRow(
                title: LocalizableKey.BreedDetail.lifeSpan,
                value: displayValue(breed.lifeSpan)
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
            return LocalizableKey.BreedDetail.notAvailable
        }

        return value
    }
}

#Preview {
    NavigationStack {
        CatBreedDetailsView(
            catBreedInfo: CatBreed(
                id: "abys",
                name: "Abyssinian",
                description: "An active and curious cat.",
                image: CatBreedImage(
                    url: "https://cdn2.thecatapi.com/images/KWdLHmOqc.jpg"
                ),
                origin: "Egypt",
                temperament: "Active, Intelligent, Playful",
                lifeSpan: "14-17"
            )
        )
    }
}
