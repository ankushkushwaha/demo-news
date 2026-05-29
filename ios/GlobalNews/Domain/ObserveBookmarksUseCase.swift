import Combine

protocol ObserveBookmarksUseCase {
    var publisher: AnyPublisher<[NewsItem], Never> { get }
}

final class ObserveBookmarksUseCaseImpl: ObserveBookmarksUseCase {
    private let repository: BookmarkRepository

    init(repository: BookmarkRepository) {
        self.repository = repository
    }

    var publisher: AnyPublisher<[NewsItem], Never> {
        repository.bookmarksPublisher
    }
}
