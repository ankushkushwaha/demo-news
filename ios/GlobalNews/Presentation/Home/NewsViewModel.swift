
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
    @Published private(set) var bookmarks: Set<NewsItem> = []

    private var task: Task<Void, Never>?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let fetchNewsUseCase: FetchNewsUseCase
    private let observeLocationUseCase: ObserveLocationUseCase

    init(
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        fetchNewsUseCase: FetchNewsUseCase,
        observeLocationUseCase: ObserveLocationUseCase
    ) {
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.observeLocationUseCase = observeLocationUseCase
        
        bind()
        
        Task {
            await observeLocationUseCase.attemptToGetLocation()
        }

    }

    private func bind() {
        observeLocationUseCase.locationUpdatePublisher
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
            .assign(to: &$bookmarks)
    }
    
    func isBookmarked(_ item: NewsItem) -> Bool {
        bookmarks.contains(item)
    }
    
    func toggleBookmark(_ item: NewsItem) {
        Task {
            await toggleBookmarkUseCase.execute(item: item)
        }
    }
    
    @discardableResult
    func fetchData(location: UserLocation) -> Task<Void, Never>? {
        task?.cancel()

        task = Task { [weak self] in
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

        return task
    }

    deinit {
        task?.cancel()
    }
}
