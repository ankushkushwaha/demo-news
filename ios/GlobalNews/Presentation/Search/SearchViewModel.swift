import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    
    enum ViewState: Equatable {
        case idle
        case loading
        case empty
        case error(String)
    }
    
    @Published var searchQuery: String = ""
    @Published private(set) var items: [NewsItem] = []
    @Published private(set) var bookmarks: Set<NewsItem> = []
    @Published private(set) var currentState: ViewState = .idle
    
    private var searchTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    private let fetchNewsUseCase: FetchNewsUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let observeBookmarksUseCase: ObserveBookmarksUseCase
    private let observeLocationUseCase: ObserveLocationUseCase
    
    init(
        fetchNewsUseCase: FetchNewsUseCase,
        toggleBookmarkUseCase: ToggleBookmarkUseCase,
        observeBookmarksUseCase: ObserveBookmarksUseCase,
        observeLocationUseCase: ObserveLocationUseCase
    ) {
        self.fetchNewsUseCase = fetchNewsUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.observeBookmarksUseCase = observeBookmarksUseCase
        self.observeLocationUseCase = observeLocationUseCase
        
        bind()
    }
    
    private func bind() {
        
        let locationPublisher = observeLocationUseCase.locationUpdatePublisher
            .receive(on: DispatchQueue.main)
            .map { Optional($0) }
            .catch { _ in Just(nil) }
            .prepend(nil)
        
        $searchQuery
            .debounce(for: .milliseconds(500),
                      scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest(locationPublisher)
            .sink { [weak self] searchQuery, location in
                guard let self else { return }
                searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
                    ? reset()
                    : search(query: searchQuery, location: location)
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
        Task { await toggleBookmarkUseCase.execute(item: item) }
    }
    
    private func search(query: String, location: UserLocation?) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            currentState = .loading
            do {
                let results = try await fetchNewsUseCase.execute(topic: query, location: location)
                guard !Task.isCancelled else { return }
                items = results
                currentState = results.isEmpty ? .empty : .idle
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
    
    private func reset() {
        searchTask?.cancel()
        items = []
        currentState = .idle
    }
    
    deinit {
        searchTask?.cancel()
    }
}
