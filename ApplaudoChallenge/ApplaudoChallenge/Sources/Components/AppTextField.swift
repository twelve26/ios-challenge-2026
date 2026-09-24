import SwiftUI

struct AppTextField: View {

    let label: String
    var placeholder: String = ""
    @Binding var text: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var icon: String?

    private var hasError: Bool { errorMessage != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // Label
            Text(label)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            // Text Field
            HStack(spacing: AppTheme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(hasError ? AppTheme.Colors.error : AppTheme.Colors.textSecondary)
                        .frame(width: 20)
                }

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(hasError ? AppTheme.Colors.error : AppTheme.Colors.border, lineWidth: 1)
            )

            // Error Message
            if let errorMessage {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                    Text(errorMessage)
                        .font(AppTheme.Fonts.caption)
                }
                .foregroundColor(AppTheme.Colors.error)
            }
        }
    }
}

// MARK: - Preview

#Preview("App Text Fields") {
    VStack(spacing: AppTheme.Spacing.lg) {
        AppTextField(
            label: LocalizableKey.Preview.breedName,
            placeholder: LocalizableKey.Preview.enterBreedName,
            text: .constant("Persian"),
            icon: "cat"
        )

        AppTextField(
            label: LocalizableKey.Preview.email,
            placeholder: LocalizableKey.Preview.enterEmail,
            text: .constant(""),
            errorMessage: LocalizableKey.Preview.invalidEmail,
            keyboardType: .emailAddress,
            icon: "envelope"
        )
    }
    .padding(AppTheme.Spacing.lg)
}
