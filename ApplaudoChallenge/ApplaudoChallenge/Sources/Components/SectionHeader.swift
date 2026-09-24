import SwiftUI

struct SectionHeader: View {

    let title: String
    var subtitle: String?
    var systemImage: String = "square.grid.2x2"

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(AppTheme.Colors.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Section Header") {
    VStack(spacing: AppTheme.Spacing.lg) {
        SectionHeader(
            title: LocalizableKey.Preview.breedInformation,
            subtitle: LocalizableKey.Preview.basicDetails,
            systemImage: "info.circle"
        )

        SectionHeader(
            title: LocalizableKey.Preview.appearance,
            systemImage: "paintpalette"
        )
    }
    .padding(AppTheme.Spacing.lg)
}
