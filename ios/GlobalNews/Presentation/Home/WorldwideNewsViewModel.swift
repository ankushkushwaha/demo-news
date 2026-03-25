import Combine

@MainActor
final class WorldwideNewsViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
    }

    @Published private(set) var currentState: ViewState = .idle
    @Published private(set) var items: [NewsItem] = []
    @Published private var bookmarks: Set<NewsItem> = []

    private var task: Task<Void, Never>?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let fetchNewsUseCase: FetchAllNewsUseCase
    private let scheduler: TaskScheduler

    init(
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        fetchNewsUseCase: FetchAllNewsUseCase,
        scheduler: TaskScheduler
    ) {
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.scheduler = scheduler
        
        bind()
    }
    
    private func bind() {
        observeBookmarksUseCase.publisher
            .assign(to: &$bookmarks)
    }
    
    func isBookmarked(_ item: NewsItem) -> Bool {
        bookmarks.contains(item)
    }
    
    func toggleBookmark(_ item: NewsItem) {
        scheduler.schedule { [weak self] in
            guard let self else { return }
            await toggleBookmarkUseCase.execute(item: item)
        }
    }
    
    func fetchData() {
        task?.cancel()

        task = scheduler.schedule { @MainActor [weak self] in
            guard let self else { return }

            self.currentState = .loading

            do {
                let items = try await fetchNewsUseCase.execute()

                guard !Task.isCancelled else { return }
                self.items = items
                self.currentState = .idle
                print("WorldWideNewsViewModel fetched")
            } catch is CancellationError {
                // Handle cancelled task here if needed
                print("task cancelled")
            } catch let error as NewsRepositoryError {
                self.currentState = .error(error.message)
            } catch {
                self.currentState = .error("Unexpected error occurred")
            }
        }
    }

    deinit {
        task?.cancel()
    }
}
