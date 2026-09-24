//
//  CatUploadFormViewModel.swift
//  ApplaudoChallenge
//
//  Created by Jhonger josias Delgado Acosta on 24/09/26.
//

import Combine
import Foundation
import NetworkLayer

final class CatUploadFormViewModel: ObservableObject {
    @Published var formData = CatFormData()
    @Published var breedName = ""
    @Published private(set) var breeds: [CatBreed] = []
    @Published private(set) var currentStep = 0
    @Published private(set) var didAttemptStepOne = false
    @Published private(set) var didAttemptStepTwo = false
    @Published private(set) var isLoadingBreeds = false
    @Published private(set) var breedErrorMessage: String?
    @Published private(set) var errorMessage: String?
    @Published var isConfirmationPresented = false

    private let storageService: LocalCatStorageServiceType
    private let breedService: BreedServiceType
    private var cancellables = Set<AnyCancellable>()

    init(
        storageService: LocalCatStorageServiceType = LocalCatStorageService(),
        breedService: BreedServiceType = NetworkLayer().breedService
    ) {
        self.storageService = storageService
        self.breedService = breedService
    }

    var buttonTitle: String {
        currentStep == 2
            ? LocalizableKey.CatUpload.create
            : LocalizableKey.CatUpload.next
    }

    func fetchBreeds() {
        guard breeds.isEmpty, !isLoadingBreeds else { return }

        isLoadingBreeds = true
        breedErrorMessage = nil

        breedService
            .fetchBreeds(pagination: Pagination(page: 0, limit: 100))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingBreeds = false
                    if case .failure(let error) = completion {
                        self?.breedErrorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] breeds in
                    self?.breeds = breeds.sorted {
                        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                }
            )
            .store(in: &cancellables)
    }

    func updateBreedName(_ name: String) {
        breedName = name
        formData.basicInformation.breed = breeds.first {
            $0.name.compare(name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }

        if breeds.isEmpty {
            fetchBreeds()
        }
    }

    func selectBreed(_ breed: CatBreed) {
        breedName = breed.name
        formData.basicInformation.breed = breed
    }

    func performPrimaryAction() {
        switch currentStep {
        case 0:
            didAttemptStepOne = true
            guard formData.isPhaseOneValid else { return }
            currentStep = 1
        case 1:
            didAttemptStepTwo = true
            guard formData.isPhaseTwoValid else { return }
            currentStep = 2
        default:
            saveCat()
        }
    }

    func clearError() {
        errorMessage = nil
    }

    @discardableResult
    private func saveCat() -> CatProfile? {
        guard let profile = formData.makeProfile() else { return nil }

        do {
            try storageService.save(profile)
            errorMessage = nil
            resetForm()
            isConfirmationPresented = true
            return profile
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func resetForm() {
        formData = CatFormData()
        breedName = ""
        currentStep = 0
        didAttemptStepOne = false
        didAttemptStepTwo = false
    }
}
