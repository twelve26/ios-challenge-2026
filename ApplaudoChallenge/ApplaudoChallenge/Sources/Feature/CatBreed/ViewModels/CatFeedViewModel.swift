//
//  CatFeedViewModel.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import Combine
import Foundation
import NetworkLayer

private enum Constants {
    static var prefetchValue: Int = 15
    static var prefetchThreshold: Int = 5
}

final class CatFeedViewModel: ObservableObject {
    @Published private(set) var breeds: [CatBreed] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var canLoadMore = true
    @Published private(set) var errorMessage: String?
    @Published private(set) var paginationErrorMessage: String?

    private let breedService: BreedServiceType
    private let pageSize: Int
    private let prefetchThreshold: Int
    private var currentPage = 0
    private var cancellables = Set<AnyCancellable>()

    init(
        breedService: BreedServiceType = NetworkLayer().breedService,
        pageSize: Int = Constants.prefetchValue,
        prefetchThreshold: Int = Constants.prefetchThreshold
    ) {
        self.breedService = breedService
        self.pageSize = max(1, pageSize)
        self.prefetchThreshold = max(1, prefetchThreshold)
    }

    func fetchBreeds() {
        guard !isLoading, !isLoadingNextPage else { return }

        currentPage = 0
        canLoadMore = true
        breeds = []
        isLoading = true
        errorMessage = nil
        paginationErrorMessage = nil

        requestPage(0, isInitialPage: true)
    }

    func loadMoreIfNeeded(currentBreed: CatBreed) {
        guard canLoadMore,
              !isLoading,
              !isLoadingNextPage,
              let currentIndex = breeds.firstIndex(where: { $0.id == currentBreed.id })
        else {
            return
        }

        let triggerIndex = max(breeds.count - prefetchThreshold, 0)
        guard currentIndex >= triggerIndex else { return }

        loadNextPage()
    }

    func retryLoadingNextPage() {
        loadNextPage()
    }

    private func loadNextPage() {
        guard canLoadMore, !isLoading, !isLoadingNextPage else { return }

        isLoadingNextPage = true
        paginationErrorMessage = nil
        requestPage(currentPage + 1, isInitialPage: false)
    }

    private func requestPage(_ page: Int, isInitialPage: Bool) {
        breedService
            .fetchBreeds(pagination: Pagination(page: page, limit: pageSize))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }

                    if isInitialPage {
                        isLoading = false
                    } else {
                        isLoadingNextPage = false
                    }

                    if case .failure(let error) = completion {
                        if isInitialPage {
                            errorMessage = userMessage(for: error)
                        } else {
                            paginationErrorMessage = userMessage(for: error)
                        }
                    }
                },
                receiveValue: { [weak self] newBreeds in
                    guard let self else { return }

                    if isInitialPage {
                        breeds = newBreeds
                    } else {
                        let existingIDs = Set(breeds.map(\.id))
                        breeds.append(contentsOf: newBreeds.filter { !existingIDs.contains($0.id) })
                    }

                    currentPage = page
                    canLoadMore = newBreeds.count == pageSize
                }
            )
            .store(in: &cancellables)
    }

    private func userMessage(for error: NetworkError) -> String {
        switch error {
        case .serverError(let statusCode, _):
            return String(format: LocalizableKey.BreedList.serverError, statusCode)
        case .decodingFailed:
            return LocalizableKey.BreedList.decodingError
        case .unknown:
            return LocalizableKey.BreedList.connectionError
        }
    }
}
