
import Foundation
import Combine

@MainActor
final class NewsViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle(String?)
        case loading
        case error(String)
    }

    @Published private(set) var currentState: ViewState = .idle(nil)
    @Published private(set) var items: [NewsItem] = []
    @Published private var bookmarks: Set<NewsItem> = []

    private var task: Task<Void, Never>?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let fetchNewsUseCase: FetchNewsUseCase
    private let observeLocationUseCase: ObserveLocationUseCase
    private let scheduler: TaskScheduler

    init(
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        fetchNewsUseCase: FetchNewsUseCase,
        observeLocationUseCase: ObserveLocationUseCase,
        scheduler: TaskScheduler
    ) {
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.observeLocationUseCase = observeLocationUseCase
        self.scheduler = scheduler
        
        bind()
        
        Task {
            await observeLocationUseCase.attemptToGetLocation()
        }
    }

    private func bind() {
        observeLocationUseCase.locationUpdatePublisher
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    currentState = .error(error.message ?? "Unknown error")
                }
            } receiveValue: { [weak self] location in
                self?.fetchData(location: location)
            }
            .store(in: &cancellables)
        
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
