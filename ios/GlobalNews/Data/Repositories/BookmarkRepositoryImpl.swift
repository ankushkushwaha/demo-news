import Combine

protocol BookmarkRepository {
    var bookmarksPublisher: AnyPublisher<[NewsItem], Never> { get }
    func toggle(_ item: NewsItem) async
}

final class BookmarkRepositoryImpl: BookmarkRepository {
    private let store: BookmarkStore

    init(store: BookmarkStore) {
        self.store = store
    }

    var bookmarksPublisher: AnyPublisher<[NewsItem], Never> {
        store.publisher
    }

    func toggle(_ item: NewsItem) async {
        await store.toggle(item)
    }
}
