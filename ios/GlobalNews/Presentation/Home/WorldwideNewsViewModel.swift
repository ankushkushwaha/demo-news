import Combine
import Foundation

@MainActor
final class WorldwideNewsViewModel: ObservableObject, AlertPresentable {

    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
    }

    @Published private(set) var currentState: ViewState = .idle
    @Published private(set) var items: [NewsItem] = []
    @Published private(set) var lastUpdatedDate: Date?
    
    @Published private var bookmarks: [NewsItem] = []
    @Published var alertMessage: String?
    
    private var task: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let fetchNewsUseCase: FetchWorldwideNewsUseCase
    private let scheduler: TaskScheduler

    init(
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        fetchNewsUseCase: FetchWorldwideNewsUseCase,
        scheduler: TaskScheduler
    ) {
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.scheduler = scheduler
        
        bind()
        
        fetchData()
    }
    
    private func bind() {
        observeBookmarksUseCase.publisher
            .assign(to: &$bookmarks)
    }
    
    func isBookmarked(_ item: NewsItem) -> Bool {
        bookmarks.contains(item)
    }
    
    func toggleBookmark(_ item: NewsItem) {
        scheduler.schedule { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await toggleBookmarkUseCase.execute(item: item)
            } catch let error as BookmarkRepositoryError {
                self.alertMessage = error.errorDescription
            } catch {
                self.alertMessage = "Unexpected error occurred."
            }
        }
    }

    func fetchData(isRefresh: Bool = false) {
        task?.cancel()

        task = scheduler.schedule { @MainActor [weak self] in
            guard let self else { return }

            if !isRefresh {
                self.currentState = .loading
            }

            do {
                let items = try await fetchNewsUseCase.execute()

                guard !Task.isCancelled else { return }
                self.items = items
                self.lastUpdatedDate = Date()
                self.currentState = .idle
                
                print("Fetched")
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
    
    func refresh() {
        fetchData(isRefresh: true)
    }
    
    deinit {
        task?.cancel()
    }
}
