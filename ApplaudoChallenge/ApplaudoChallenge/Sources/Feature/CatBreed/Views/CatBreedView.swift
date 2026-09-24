//
//  CatBreedView.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import SwiftUI

struct CatBreedView: View {
    @StateObject private var viewModel = CatFeedViewModel()
    
    var body: some View {
        NavigationStack {
            CatBreedListView(viewModel: viewModel)
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .navigationTitle(LocalizableKey.BreedList.navigationTitle)
        }
    }
}

struct CatBreedListView: View {
    @ObservedObject var viewModel: CatFeedViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.breeds.isEmpty {
                ProgressView(LocalizableKey.BreedList.loading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.breeds.isEmpty {
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: LocalizableKey.BreedList.errorTitle,
                    message: errorMessage,
                    buttonTitle: LocalizableKey.BreedList.retry,
                    action: viewModel.fetchBreeds
                )
            } else if viewModel.breeds.isEmpty {
                EmptyStateView(
                    systemImage: "cat",
                    title: LocalizableKey.BreedList.emptyTitle,
                    message: LocalizableKey.BreedList.emptyMessage
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(viewModel.breeds, id: \.id) { breed in
                            NavigationLink(destination: CatBreedDetailsView(catBreedInfo: breed)) {
                                AppCard(
                                    title: breed.name,
                                    subtitle: breed.description ?? "",
                                    imageSystemName: "cat.fill",
                                    urlImage: breed.image?.url,
                                    lineLimit: 2
                                )
                            }
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentBreed: breed)
                            }
                        }

                        if viewModel.isLoadingNextPage {
                            ProgressView(LocalizableKey.BreedList.loadingMore)
                                .padding(.vertical, AppTheme.Spacing.md)
                        } else if let paginationError = viewModel.paginationErrorMessage {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text(paginationError)
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.error)
                                    .multilineTextAlignment(.center)

                                Button(LocalizableKey.BreedList.retry) {
                                    viewModel.retryLoadingNextPage()
                                }
                                .font(AppTheme.Fonts.headline)
                                .foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(.vertical, AppTheme.Spacing.md)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }
                .background(AppTheme.Colors.background)
            }
        }
        .task {
            if viewModel.breeds.isEmpty {
                viewModel.fetchBreeds()
            }
        }
    }
}

#Preview {
    CatBreedView()
}
