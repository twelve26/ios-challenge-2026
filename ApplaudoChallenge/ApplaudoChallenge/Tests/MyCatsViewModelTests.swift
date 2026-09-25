import Foundation
import NetworkLayer
import Testing
@testable import ApplaudoChallenge

struct MyCatsViewModelTests {
    @Test func fetchCatsPublishesStoredProfiles() {
        let cat = makeCat()
        let storage = MyCatsStorageSpy(cats: [cat])
        let viewModel = MyCatsViewModel(storageService: storage)

        viewModel.fetchCats()

        #expect(viewModel.cats == [cat])
        #expect(viewModel.errorMessage == nil)
    }

    @Test func fetchFailurePublishesErrorWithoutCrashing() {
        let storage = MyCatsStorageSpy(fetchError: MyCatsStorageTestError.fetch)
        let viewModel = MyCatsViewModel(storageService: storage)

        viewModel.fetchCats()

        #expect(viewModel.cats.isEmpty)
        #expect(viewModel.errorMessage == MyCatsStorageTestError.fetch.localizedDescription)
    }

    @Test func deleteCatRemovesOnlySelectedProfile() {
        let firstCat = makeCat(name: "Milo")
        let secondCat = makeCat(name: "Luna")
        let storage = MyCatsStorageSpy(cats: [firstCat, secondCat])
        let viewModel = MyCatsViewModel(storageService: storage)
        viewModel.fetchCats()

        viewModel.deleteCat(id: firstCat.id)

        #expect(viewModel.cats == [secondCat])
        #expect(storage.deletedIDs == [firstCat.id])
        #expect(viewModel.errorMessage == nil)
    }

    @Test func deleteFailureReloadsProfilesAndPreservesDeletionError() {
        let cat = makeCat()
        let storage = MyCatsStorageSpy(
            cats: [cat],
            deleteError: MyCatsStorageTestError.delete
        )
        let viewModel = MyCatsViewModel(storageService: storage)
        viewModel.fetchCats()

        viewModel.deleteCat(id: cat.id)

        #expect(viewModel.cats == [cat])
        #expect(viewModel.errorMessage == MyCatsStorageTestError.delete.localizedDescription)
    }

    @Test func invalidDeletionOffsetIsIgnoredSafely() {
        let cat = makeCat()
        let storage = MyCatsStorageSpy(cats: [cat])
        let viewModel = MyCatsViewModel(storageService: storage)
        viewModel.fetchCats()

        viewModel.deleteCats(at: IndexSet(integer: 99))

        #expect(viewModel.cats == [cat])
        #expect(storage.deletedIDs.isEmpty)
    }

    private func makeCat(
        id: UUID = UUID(),
        name: String = "Milo"
    ) -> CatProfile {
        CatProfile(
            id: id,
            name: name,
            breed: CatBreed(id: "beng", name: "Bengal"),
            age: 2,
            shortDescription: "Playful cat"
        )
    }
}

private enum MyCatsStorageTestError: LocalizedError {
    case fetch
    case delete

    var errorDescription: String? {
        switch self {
        case .fetch:
            return "Expected fetch failure."
        case .delete:
            return "Expected delete failure."
        }
    }
}

private final class MyCatsStorageSpy: LocalCatStorageServiceType {
    private var cats: [CatProfile]
    private let fetchError: Error?
    private let deleteError: Error?
    private(set) var deletedIDs: [UUID] = []

    init(
        cats: [CatProfile] = [],
        fetchError: Error? = nil,
        deleteError: Error? = nil
    ) {
        self.cats = cats
        self.fetchError = fetchError
        self.deleteError = deleteError
    }

    func fetchCats() throws -> [CatProfile] {
        if let fetchError {
            throw fetchError
        }
        return cats
    }

    func save(_ cat: CatProfile) throws {
        cats.append(cat)
    }

    func deleteCat(id: UUID) throws {
        if let deleteError {
            throw deleteError
        }
        deletedIDs.append(id)
        cats.removeAll { $0.id == id }
    }
}
