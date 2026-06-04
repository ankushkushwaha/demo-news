
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
    
    private func makeLocationRepository() -> LocationRepository {
        LocationRepositoryImpl(service: services.locationService)
    }
    
    private func makeNewsRepository() -> NewsRepository {
        NewsRepositoryImpl(service: services.newsService)
    }
    
    private func makeBookmarkRepository() -> BookmarkRepository {
        BookmarkRepositoryImpl(store: states.bookmarkStore)
    }

    private func makeAnalyticsService() -> AnalyticsService {
        services.analyticsService
    }

    func makeLocalNewsViewModel() -> LocalNewsViewModel {
        LocalNewsViewModel(
            toggleBookmarkUseCase: ToggleBookmarkUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            observeBookmarksUseCase: ObserveBookmarksUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            fetchNewsUseCase: FetchTopicNewsUseCaseImpl(
                newsRepository: makeNewsRepository()
            ),
            observeLocationUseCase: ObserveLocationUseCaseImpl(
                locationRepository: makeLocationRepository()
            ),
            scheduler: DefaultTaskScheduler()
        )
    }
    func makeWorldwideNewsViewModel() -> WorldwideNewsViewModel {
        WorldwideNewsViewModel(
            toggleBookmarkUseCase: ToggleBookmarkUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            observeBookmarksUseCase: ObserveBookmarksUseCaseImpl(
                repository: makeBookmarkRepository()
            ),
            fetchNewsUseCase: FetchWorldwideNewsUseCaseImpl(
                newsRepository: makeNewsRepository(),
                analyticsService: makeAnalyticsService()
            ),
            scheduler: DefaultTaskScheduler()
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
            fetchNewsUseCase: FetchTopicNewsUseCaseImpl(
                newsRepository: makeNewsRepository()
            ),
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
