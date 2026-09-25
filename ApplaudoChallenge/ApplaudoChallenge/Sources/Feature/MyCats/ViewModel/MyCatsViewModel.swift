//
//  MyCatsViewModel.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import Combine
import Foundation

final class MyCatsViewModel: ObservableObject {
    @Published private(set) var cats: [CatProfile] = []
    @Published private(set) var errorMessage: String?

    private let storageService: LocalCatStorageServiceType

    init(storageService: LocalCatStorageServiceType = LocalCatStorageService()) {
        self.storageService = storageService
    }

    func fetchCats() {
        do {
            cats = try storageService.fetchCats()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCats(at offsets: IndexSet) {
        let catsToDelete = offsets
            .filter { cats.indices.contains($0) }
            .map { cats[$0] }
        let deletedIDs = Set(catsToDelete.map(\.id))

        do {
            for cat in catsToDelete {
                try storageService.deleteCat(id: cat.id)
            }
            cats.removeAll { deletedIDs.contains($0.id) }
            errorMessage = nil
        } catch {
            let deletionErrorMessage = error.localizedDescription
            fetchCats()
            errorMessage = deletionErrorMessage
        }
    }

    func deleteCat(id: UUID) {
        do {
            try storageService.deleteCat(id: id)
            cats.removeAll { $0.id == id }
            errorMessage = nil
        } catch {
            let deletionErrorMessage = error.localizedDescription
            fetchCats()
            errorMessage = deletionErrorMessage
        }
    }
}
