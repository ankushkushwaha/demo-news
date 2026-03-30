
import Testing
import Combine
import Foundation

@testable import News

@Suite("WorldwideNewsViewModel")
@MainActor
struct WorldwideNewsViewModelTests {

    let fetchNewsUseCase: MockFetchAllNewsUseCase
    let toggleBookmarkUseCase: MockToggleBookmarkUseCase
    let observeBookmarksUseCase: MockObserveBookmarksUseCase
    let scheduler: TestTaskScheduler
    let sut: WorldwideNewsViewModel

    init() {
        fetchNewsUseCase = MockFetchAllNewsUseCase()
        toggleBookmarkUseCase = MockToggleBookmarkUseCase()
        observeBookmarksUseCase = MockObserveBookmarksUseCase()
        scheduler = TestTaskScheduler()

        sut = WorldwideNewsViewModel(
            toggleBookmarkUseCase: toggleBookmarkUseCase,
            observeBookmarksUseCase: observeBookmarksUseCase,
            fetchNewsUseCase: fetchNewsUseCase,
            scheduler: scheduler
        )
    }

    @Test("fetchData sets items and transitions to idle on success")
    func fetchData_success() async throws {
        let items = [NewsItem.stub(title: "One"), NewsItem.stub(title: "Two")]
        fetchNewsUseCase.result = .success(items)

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .idle)
        #expect(sut.items.count == 2)
        #expect(sut.items[0].title == "One")
        #expect(sut.items[1].title == "Two")
    }

    @Test("fetchData sets empty items and transitions to idle when use case returns none")
    func fetchData_emptySuccess() async throws {
        fetchNewsUseCase.result = .success([])

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .idle)
        #expect(sut.items.isEmpty)
    }

    @Test("fetchData shows error message on networkFailure")
    func fetchData_networkFailure() async {
        fetchNewsUseCase.result = .failure(NewsRepositoryError.networkFailure)

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .error(NewsRepositoryError.networkFailure.message))
        #expect(sut.items.isEmpty)
    }

    @Test("fetchData shows error message on timeout")
    func fetchData_timeout() async {
        fetchNewsUseCase.result = .failure(NewsRepositoryError.timeout)

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .error(NewsRepositoryError.timeout.message))
    }

    @Test("fetchData shows error message on notFound")
    func fetchData_notFound() async {
        fetchNewsUseCase.result = .failure(NewsRepositoryError.notFound)

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .error(NewsRepositoryError.notFound.message))
    }

    @Test("fetchData shows error message on invalidRequest")
    func fetchData_invalidRequest() async {
        fetchNewsUseCase.result = .failure(NewsRepositoryError.invalidRequest)

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .error(NewsRepositoryError.invalidRequest.message))
    }

    @Test("fetchData shows generic message on unexpected error")
    func fetchData_unexpectedError() async {
        fetchNewsUseCase.result = .failure(NSError(domain: "test", code: -1))

        await scheduler.waitForAllTasks()

        #expect(sut.currentState == .error("Unexpected error occurred"))
    }

    @Test("fetchData does not update state on CancellationError")
    func fetchData_cancellationError() async {
        fetchNewsUseCase.result = .failure(CancellationError())

        await scheduler.waitForAllTasks()

        // State stays loading (task was cancelled mid-flight, no error shown)
        #expect(sut.currentState == .loading)
        #expect(sut.items.isEmpty)
    }

    // MARK: - fetchData Re-fetch

    @Test("calling fetchData again cancels in-flight task and starts fresh")
    func fetchData_cancelsPreviousTask() async {
        // First fetch is slow — not resolved yet
        fetchNewsUseCase.result = .success([NewsItem.stub(title: "Stale")])

        // Trigger a second fetch before the first resolves
        sut.fetchData()
        fetchNewsUseCase.result = .success([NewsItem.stub(title: "Fresh")])

        await scheduler.waitForAllTasks()

        // Only the latest result should be reflected
        #expect(sut.items.first?.title == "Fresh")
        #expect(sut.currentState == .idle)
    }
    
    @Test("isBookmarked returns false when item is not bookmarked")
    func isBookmarked_false() {
        let item = NewsItem.stub()
        #expect(sut.isBookmarked(item) == false)
    }

    @Test("isBookmarked returns true after bookmark stream emits item")
    func isBookmarked_true() async {
        let item = NewsItem.stub()
        observeBookmarksUseCase.emit([item])
        #expect(sut.isBookmarked(item) == true)
    }

    @Test("isBookmarked returns false after item is removed from bookmark stream")
    func isBookmarked_removedFromBookmarks() async {
        let item = NewsItem.stub()

        observeBookmarksUseCase.emit([item])
        #expect(sut.isBookmarked(item) == true)

        observeBookmarksUseCase.emit([])
        #expect(sut.isBookmarked(item) == false)
    }

    @Test("toggleBookmark calls use case with correct item")
    func toggleBookmark_callsUseCase() async {
        let item = NewsItem.stub(title: "Toggle me")

        sut.toggleBookmark(item)
        await scheduler.waitForAllTasks()

        #expect(toggleBookmarkUseCase.capturedItem?.title == "Toggle me")
    }

    @Test("toggleBookmark can be called multiple times")
    func toggleBookmark_multipleItems() async {
        let itemA = NewsItem.stub(title: "A")
        let itemB = NewsItem.stub(title: "B")

        sut.toggleBookmark(itemA)
        sut.toggleBookmark(itemB)
        await scheduler.waitForAllTasks()

        #expect(toggleBookmarkUseCase.callCount == 2)
    }
}

// MARK: - Mocks

final class MockFetchAllNewsUseCase: FetchAllNewsUseCase {
    var result: Result<[NewsItem], Error> = .success([])

    func execute() async throws -> [NewsItem] {
        try result.get()
    }
}

extension NewsItem {
    static func stub(
        title: String = "Title",
        source: String = "Source",
        pubDate: String = "1.1.2026",
        link: String = "https://example.com",
        description: String = "Description"
    ) -> NewsItem {
        NewsItem(
            title: title,
            source: source,
            pubDate: pubDate,
            link: link,
            description: description
        )
    }
}
