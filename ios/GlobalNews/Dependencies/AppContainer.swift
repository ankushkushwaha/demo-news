
import Foundation
import Combine

/// Dependency provider
final class AppContainer: ObservableObject {
    private let states: AppStates
    private let services: AppServices
    
    init(
        states: AppStates = AppStates(),
        services: AppServices = AppServices()
    ) {
        self.states = states
        self.services = services
    }
    
    func makeLocationRepository() -> LocationRepository {
        LocationRepositoryImpl(service: services.locationService)
    }
    
    func makeNewsRepository() -> NewsRepository {
        NewsRepositoryImpl(service: services.newsService)
    }
    
    func makeBookmarkRepository() -> BookmarkRepository {
        BookmarkRepositoryImpl(store: states.bookmarkStore)
    }

    func makeNewsViewModel() -> NewsViewModel {
        NewsViewModel(
            toggleBookmarkUseCase: ToggleBookmarkUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            observeBookmarksUseCase: ObserveBookmarksUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            fetchNewsUseCase: FetchNewsUseCaseImpl(),
            observeLocationUseCase: ObserveLocationUseCaseImpl(
                locationRepository: makeLocationRepository()
            )
        )
    }
    
    func makeBookmarkViewModel() -> BookMarkViewModel {
        BookMarkViewModel(
            observeBookmarksUseCase: ObserveBookmarksUseCaseImpl(
                repository: makeBookmarkRepository(),
            ),
            toggleBookmarkUseCase: ToggleBookmarkUseCaseImpl(
                repository: makeBookmarkRepository()
            )
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            fetchNewsUseCase: FetchNewsUseCaseImpl(),
            toggleBookmarkUseCase: ToggleBookmarkUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            observeBookmarksUseCase: ObserveBookmarksUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            observeLocationUseCase: ObserveLocationUseCaseImpl(
                locationRepository: makeLocationRepository()
            ),
            
        )
    }

}
