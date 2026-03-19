import Testing
import Combine
import Foundation
@testable import News

struct NewsViewModelTests {
    
    private let scheduler: TestTaskScheduler!
    private let fetchUseCase: MockFetchNewsUseCase!
    private let locationUseCase: MockObserveLocationUseCase!
    private let toggleBookmarkUseCase: MockToggleBookmarkUseCase!
    private let observeBookmarksUsecase: MockObserveBookmarksUseCase!
    private let sut: NewsViewModel!
    
    init() async {
        scheduler = TestTaskScheduler()
        fetchUseCase = MockFetchNewsUseCase()
        locationUseCase = MockObserveLocationUseCase()
        toggleBookmarkUseCase = MockToggleBookmarkUseCase()
        observeBookmarksUsecase = MockObserveBookmarksUseCase()
        
        sut = await NewsViewModel(
            toggleBookmarkUseCase: toggleBookmarkUseCase,
            observeBookmarksUseCase: observeBookmarksUsecase,
            fetchNewsUseCase: fetchUseCase,
            observeLocationUseCase: locationUseCase,
            scheduler: scheduler
        )
    }
    
    @Test
    func locationUpdateError() async {
                
        locationUseCase.emitError(LocationRepositoryError.permissionDenied)
        
        await scheduler.waitForAllTasks()
        
        if case .error(let message) = await sut.currentState {
            #expect(message == LocationRepositoryError.permissionDenied.message)
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test
    func locationUpdateSuccess_newsFetchSuccess() async {

        let newsItem = await NewsItem(title: "title", source: "", pubDate: "1.1.2026", link: "", description: "")
        fetchUseCase.newsItems = [newsItem]
        
        let location = UserLocation(countryCode: "DE", countryName: "Germany", city: "Berlin", languageCode: "de")
        
        locationUseCase.emit(location)
        
        await scheduler.waitForAllTasks()
        
        #expect(await sut.items.count == 1)
        
        if case .idle(let string) = await sut.currentState {
            let locationName = await location.locationName
            #expect(string == locationName)
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test
    func locationUpdateSuccess_newsFetchError() async {

        fetchUseCase.error = NewsRepositoryError.networkFailure
        
        let location = UserLocation(countryCode: "DE", countryName: "Germany", city: "Berlin", languageCode: "de")

        locationUseCase.emit(location)
        
        await scheduler.waitForAllTasks()
        
        if case .error(let message) = await sut.currentState {
            #expect(message == NewsRepositoryError.networkFailure.message)
        } else {
            #expect(Bool(false))
        }
    }
        
    @Test func isBookmarked_trueWhenPresent() async {
        let item = makeNewsItem()
        observeBookmarksUsecase.emit([item])
        let result = await sut.isBookmarked(item)
        #expect(result)
    }

    @Test func isBookmarked_falseAfterCleared() async {
        let item = makeNewsItem()
        observeBookmarksUsecase.emit([item])
        #expect(await sut.isBookmarked(item))
        
        observeBookmarksUsecase.emit([])
        let result = await sut.isBookmarked(item)
        #expect(result == false)
    }
}
