//
//  CatUploadFormViewModel.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import Combine

final class CatUploadFormViewModel: ObservableObject {
    @Published var formData = CatFormData()
    @Published private(set) var errorMessage: String?

    private let storageService: LocalCatStorageServiceType

    init(storageService: LocalCatStorageServiceType = LocalCatStorageService()) {
        self.storageService = storageService
    }

    @discardableResult
    func saveCat() -> CatProfile? {
        guard let profile = formData.makeProfile() else { return nil }

        do {
            try storageService.save(profile)
            errorMessage = nil
            return profile
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
