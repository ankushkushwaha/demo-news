
import Combine


protocol ObserveBookmarksUseCase {
    var publisher: AnyPublisher<Set<NewsItem>, Never> { get }
}

final class ObserveBookmarksUseCaseImpl: ObserveBookmarksUseCase {
    private let repository: BookmarkRepository

    init(repository: BookmarkRepository) {
        self.repository = repository
    }

    var publisher: AnyPublisher<Set<NewsItem>, Never> {
        repository.bookmarksPublisher
    }
}
