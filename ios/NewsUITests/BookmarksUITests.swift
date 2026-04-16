import XCTest

final class BookmarksUITests: XCTestCase {

    var app: XCUIApplication!

    private let firstTitle  = "Swift 6 Concurrency Deep Dive"
    private let secondTitle = "Apple Vision Pro 2 Announced"
    private let thirdTitle  = "SwiftUI Performance Tips"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func launch() {
        app.launchArguments = ["UITestSimulateSuccess"]
        app.launch()
    }

    private func goToBookmarksTab() {
        app.buttons.matching(NSPredicate(format: "label == 'Bookmarks'")).firstMatch.tap()
    }

    private func goToHomeTab() {
        app.buttons.matching(NSPredicate(format: "label == 'Home'")).firstMatch.tap()
    }

    private func waitForFeedToLoad() {
        XCTAssertTrue(
            app.staticTexts[firstTitle].waitForExistence(timeout: 5),
            "Feed did not load"
        )
    }

    private func bookmarkFirstFeedItem() {
        waitForFeedToLoad()
        app.buttons["Add bookmark"].firstMatch.tap()
    }

    private func unbookmarkFirstBookmarkedItem() {
        app.buttons["Remove bookmark"].firstMatch.tap()
    }

    // MARK: - Empty State

    func test_bookmarks_noItemsShown_initially() {
        launch()
        goToBookmarksTab()

        XCTAssertFalse(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts[secondTitle].exists)
        XCTAssertFalse(app.staticTexts[thirdTitle].exists)
    }

    // MARK: - Adding Bookmarks

    func test_bookmarks_showsTitle_afterBookmarking() {
        launch()
        bookmarkFirstFeedItem()
        goToBookmarksTab()

        XCTAssertTrue(
            app.staticTexts[firstTitle].waitForExistence(timeout: 3)
        )
    }
    
    func test_bookmarks_showsOnlyBookmarkedTitle_afterBookmarking() {
        launch()
        bookmarkFirstFeedItem()
        goToBookmarksTab()

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
    }

    func test_bookmarks_titleDisappears_afterUnbookmarking() {
        launch()
        bookmarkFirstFeedItem()
        goToBookmarksTab()

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
        unbookmarkFirstBookmarkedItem()

        XCTAssertFalse(app.staticTexts[firstTitle].exists)
    }

    func test_bookmarks_itemRemovedFromList_afterUnbookmarkingFromFeed() {
        launch()

        bookmarkFirstFeedItem()

        goToBookmarksTab()
        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))

        goToHomeTab()
        
        waitForFeedToLoad()
        unbookmarkFirstBookmarkedItem()

        goToBookmarksTab()
        XCTAssertFalse(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
    }
}
