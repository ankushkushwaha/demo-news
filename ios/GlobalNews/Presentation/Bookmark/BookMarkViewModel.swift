
import Foundation
import Combine

@MainActor
final class BookMarkViewModel: ObservableObject {
    @Published private(set) var bookmarks: Set<NewsItem> = []
    
    private var cancellable: Set<AnyCancellable> = []
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    
    var bookmarksList: [NewsItem] {
        Array(bookmarks)
    }
    
    init(
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
    ) {
        
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase

        bind()
    }
    
    private func bind() {
        observeBookmarksUseCase.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.bookmarks = items
            }
            .store(in: &cancellable)
    }
    
    func isBookmarked(_ item: NewsItem) -> Bool {
        bookmarks.contains(item)
    }
    
    func toggleBookmark(_ item: NewsItem) {
        Task {
            await toggleBookmarkUseCase.execute(item: item)
        }
    }

}
