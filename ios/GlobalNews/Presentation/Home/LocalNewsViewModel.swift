
import Foundation
import Combine

@MainActor
final class LocalNewsViewModel: ObservableObject, AlertPresentable {

    enum ViewState: Equatable {
        case idle(String?)
        case loading
        case error(String)
    }

    @Published private(set) var currentState: ViewState = .idle(nil)
    @Published private(set) var items: [NewsItem] = []
    @Published private(set) var lastUpdatedDate: Date?

    @Published private var bookmarks: [NewsItem] = []
    @Published var alertMessage: String?

    private var currentLocation: UserLocation?
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
                    self.currentLocation = location
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
                self.alertMessage = error.errorDescription
            } catch {
                self.alertMessage = "Unexpected error occurred."
            }
        }
    }
    
    private func fetchData(location: UserLocation, isRefresh: Bool = false) {
        task?.cancel()

        task = scheduler.schedule { @MainActor [weak self] in
            guard let self else { return }

            if !isRefresh {
                self.currentState = .loading
            }

            do {
                let items = try await fetchNewsUseCase.execute(topic: nil, location: location)

                guard !Task.isCancelled else { return }
                self.items = items
                self.lastUpdatedDate = Date()
                self.currentState = .idle(location.locationName)
                print("FetchData")
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
    
    func refresh() async {
        guard let currentLocation else {
            self.alertMessage = "Could not detect current location"
            return
        }
        fetchData(location: currentLocation, isRefresh: true)
    }
    
    deinit {
        task?.cancel()
    }
}
