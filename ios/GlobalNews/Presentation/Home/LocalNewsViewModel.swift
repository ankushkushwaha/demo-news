
import Foundation
import Combine

@MainActor
final class LocalNewsViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle(String?)
        case loading
        case error(String)
    }

    @Published private(set) var currentState: ViewState = .idle(nil)
    @Published private(set) var items: [NewsItem] = []

    @Published private var bookmarks: [NewsItem] = []
    @Published var bookmarkError: String?

    private var task: Task<Void, Never>?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let fetchNewsUseCase: FetchTopicNewsUseCase
    private let observeLocationUseCase: ObserveLocationUseCase
    private let scheduler: TaskScheduler

    init(
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        fetchNewsUseCase: FetchTopicNewsUseCase,
        observeLocationUseCase: ObserveLocationUseCase,
        scheduler: TaskScheduler
    ) {
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.observeLocationUseCase = observeLocationUseCase
        self.scheduler = scheduler
        
        bind()
        
        attemptToGetLocation()
    }
    
    func attemptToGetLocation() {
        Task {
            await observeLocationUseCase.attemptToGetLocation()
        }
    }

    private func bind() {
        observeLocationUseCase.locationUpdatePublisher
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let location):
                    self.fetchData(location: location)
                case .failure(let error):
                    self.currentState = .error(error.message ?? "Unknown error")
                }
            }
            .store(in: &cancellables)
        
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
                self.bookmarkError = error.errorDescription
            } catch {
                self.bookmarkError = "Unexpected error occurred."
            }
        }
    }
    
    private func fetchData(location: UserLocation) {
        task?.cancel()

        task = scheduler.schedule { @MainActor [weak self] in
            guard let self else { return }

            currentState = .loading

            do {
                let items = try await fetchNewsUseCase.execute(topic: nil, location: location)

                guard !Task.isCancelled else { return }
                self.items = items
                currentState = .idle(location.locationName)
            } catch is CancellationError {
                // Handle cancelled task here if needed
                print("task cancelled")
            } catch let error as NewsRepositoryError {
                currentState = .error(error.message)
            } catch {
                currentState = .error("Unexpected error occurred")
            }
        }
    }

    deinit {
        task?.cancel()
    }
}
