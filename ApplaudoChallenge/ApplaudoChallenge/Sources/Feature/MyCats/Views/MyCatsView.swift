//
//  MyCatsView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct MyCatsView: View {
    @StateObject private var viewModel = MyCatsViewModel()
    var onAddCat: () -> Void = {}

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage,
                   viewModel.cats.isEmpty {
                    EmptyStateView(
                        systemImage: "exclamationmark.triangle",
                        title: LocalizableKey.MyCats.errorTitle,
                        message: errorMessage,
                        buttonTitle: LocalizableKey.MyCats.retry,
                        action: viewModel.fetchCats
                    )
                } else if viewModel.cats.isEmpty {
                    EmptyStateView(
                        systemImage: "cat",
                        title: LocalizableKey.MyCats.emptyTitle,
                        message: LocalizableKey.MyCats.placeholder,
                        buttonTitle: LocalizableKey.MyCats.addCat,
                        action: onAddCat
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.md) {
                            ForEach(Array(viewModel.cats.enumerated()), id: \.element.id) { index, cat in
                                NavigationLink(destination: MyCatDetailsView(cat: cat)) {
                                    AppCard(
                                        title: cat.name,
                                        subtitle: cat.breed.name,
                                        imageSystemName: index.isMultiple(of: 2)
                                            ? "cat.fill"
                                            : "cat"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                    }
                    .background(AppTheme.Colors.background)
                }
            }
            .navigationTitle(LocalizableKey.MyCats.navigationTitle)
            .task {
                viewModel.fetchCats()
            }
        }
    }
}

#Preview {
    MyCatsView()
}
