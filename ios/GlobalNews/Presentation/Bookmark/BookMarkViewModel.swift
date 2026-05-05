import Foundation
import Combine

@MainActor
final class BookMarkViewModel: ObservableObject {
    @Published private(set) var bookmarks: [NewsItem] = []
    @Published var bookmarkError: String?

    private var cancellable: Set<AnyCancellable> = []
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase

    init(
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        toggleBookmarkUseCase: ToggleBookmarkUseCase
    ) {
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        bind()
    }

    private func bind() {
        observeBookmarksUseCase.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.bookmarks = items
            }
            .store(in: &cancellable)
    }

    func isBookmarked(_ item: NewsItem) -> Bool {
        bookmarks.contains(item)
    }

    func toggleBookmark(_ item: NewsItem) {
        Task {
            do {
                try await toggleBookmarkUseCase.execute(item: item)
            } catch let error as BookmarkRepositoryError {
                self.bookmarkError = error.errorDescription
            } catch {
                self.bookmarkError = "Unexpected error occurred."
            }
        }
    }
}
