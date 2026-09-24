import Foundation

protocol LocalCatStorageServiceType {
    func fetchCats() throws -> [CatProfile]
    func save(_ cat: CatProfile) throws
    func deleteCat(id: UUID) throws
}

enum LocalCatStorageError: LocalizedError {
    case applicationSupportDirectoryUnavailable

    var errorDescription: String? {
        switch self {
        case .applicationSupportDirectoryUnavailable:
            return "The local storage directory is unavailable."
        }
    }
}

final class LocalCatStorageService: LocalCatStorageServiceType {
    private let fileManager: FileManager
    private let customFileURL: URL?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.customFileURL = fileURL
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder
        self.decoder = JSONDecoder()
    }

    func fetchCats() throws -> [CatProfile] {
        let fileURL = try storageFileURL()
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }

        return try decoder.decode(
            [CatProfile].self,
            from: Data(contentsOf: fileURL)
        )
    }

    func save(_ cat: CatProfile) throws {
        var cats = try fetchCats()

        if let index = cats.firstIndex(where: { $0.id == cat.id }) {
            cats[index] = cat
        } else {
            cats.append(cat)
        }

        try persist(cats)
    }

    func deleteCat(id: UUID) throws {
        var cats = try fetchCats()
        cats.removeAll { $0.id == id }
        try persist(cats)
    }

    private func persist(_ cats: [CatProfile]) throws {
        let fileURL = try storageFileURL()
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try encoder.encode(cats).write(to: fileURL, options: .atomic)
    }

    private func storageFileURL() throws -> URL {
        if let customFileURL {
            return customFileURL
        }

        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw LocalCatStorageError.applicationSupportDirectoryUnavailable
        }

        return applicationSupportURL
            .appendingPathComponent("ApplaudoChallenge", isDirectory: true)
            .appendingPathComponent("cats.json", isDirectory: false)
    }
}
