import Combine

protocol BookmarkRepository {
    var bookmarksPublisher: AnyPublisher<[NewsItem], Never> { get }
    func toggle(_ item: NewsItem) async throws
}

final class BookmarkRepositoryImpl: BookmarkRepository {

    private let store: BookmarkStore

    init(store: BookmarkStore) {
        self.store = store
    }

    var bookmarksPublisher: AnyPublisher<[NewsItem], Never> {
        store.publisher
    }

    func toggle(_ item: NewsItem) async throws {
        do {
            try await store.toggle(item)
        } catch let storeError as BookmarkStoreError {
            throw map(storeError)
        }
    }

    private func map(_ storeError: BookmarkStoreError) -> BookmarkRepositoryError {
        switch storeError {
        case .addBookmarkFailed:
            return .addBookmarkFailed
        case .removeBookmarkFailed:
            return .removeBookmarkFailed
        case .decodingFailed:
            return .unknown
        }
    }
}

enum BookmarkRepositoryError: Error {
    case addBookmarkFailed
    case removeBookmarkFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .addBookmarkFailed: 
            return "Failed to add bookmark."
        case .removeBookmarkFailed:
            return "Failed to remove bookmark."
        case .unknown: return 
            "An unknown error occurred."
        }
    }
}
