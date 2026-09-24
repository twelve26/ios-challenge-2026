import Foundation
import SwiftUI

struct RemoteImageView<Fallback: View>: View {
    let urlString: String?
    var contentMode: ContentMode = .fill
    private let fallback: () -> Fallback

    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder fallback: @escaping () -> Fallback
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.fallback = fallback
    }

    var body: some View {
        Color.clear
            .overlay {
                Group {
                    if let urlString,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            image(for: phase)
                        }
                    } else {
                        fallback()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipped()
    }

    @ViewBuilder
    private func image(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            ProgressView()
                .tint(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        case .failure:
            fallback()
        @unknown default:
            fallback()
        }
    }
}
