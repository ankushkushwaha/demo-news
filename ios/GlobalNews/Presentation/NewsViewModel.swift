
import Foundation
import Combine

final class NewsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle(String?)
        case loading
        case error(String)
    }
    @Published private(set) var currentState: ViewState = .idle(nil)
    @Published private(set) var items: [NewsItem] = []

    private var task: Task<Void, Error>?
    private let fetchNewsUseCase: FetchNewsUseCase
    private let observeLocationUseCase: ObserveLocationUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    init(
        fetchNewsUseCase: FetchNewsUseCase = FetchNewsUseCaseImpl(),
        observeLocationUseCase: ObserveLocationUseCase = ObserveLocationUseCaseImpl()
    ) {
        self.fetchNewsUseCase = fetchNewsUseCase
        self.observeLocationUseCase = observeLocationUseCase
       
        binding()
    }
    
    func binding() {
        observeLocationUseCase.locationUpdatePublisher
            .sink { [weak self] completion in
                guard let self else { return }

                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self.currentState = .error(error.message ?? "Unknown error")
                }
            } receiveValue: { [weak self] location in
                guard let self else { return }
                self.fetchData(location: location)
            }
            .store(in: &cancellables)
        
    }
    
    @discardableResult
    func fetchData(location: UserLocation) -> Task<Void, Error>? {
        
        task?.cancel()
        
        task = Task { [weak self] in
            guard let self else { return }
            
            self.currentState = .loading
            
            do {
                let items = try await fetchNewsUseCase.execute(topic: nil, location: location)
                self.items = items
                
                self.currentState = .idle(location.locationName)
            } catch let error as NewsRepositoryError {
                self.currentState = .error(error.messsage)
            } catch {
                self.currentState = .error("Unexpected error occurred")
            }
        }
        
        return task
    }
    
    
    deinit {
        task?.cancel()
    }
}

