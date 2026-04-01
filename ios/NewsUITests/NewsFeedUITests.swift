import XCTest
@testable import News

final class NewsFeedUITests: XCTestCase {

    var app: XCUIApplication!

    let items = [
            "Swift 6 Concurrency Deep Dive",
            "Apple Vision Pro 2 Announced",
            "SwiftUI Performance Tips"
        ]
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func launch(mode: String = "UITestSimulateSuccess") {
        app.launchArguments = [mode]
        app.launch()
    }

    // MARK: - Success

    func test_newsFeed_showsFirstItem() {
        launch()

        XCTAssertTrue(
            app.staticTexts[items[0]].waitForExistence(timeout: 5)
        )
    }

    func test_newsFeed_showsAllItems() {
        launch()

        XCTAssertTrue(app.staticTexts[items[0]].waitForExistence(timeout: 5))
        items.dropFirst().forEach {
            XCTAssertTrue(app.staticTexts[$0].exists)
        }
    }

 

    func test_newsFeed_noErrorShown_onSuccess() {
        launch()

        XCTAssertTrue(app.staticTexts[items[0]].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["error_message_label"].exists)
    }

    // MARK: - Error

    func test_newsFeed_showsErrorLabel_onFailure() {
        launch(mode: "UITestSimulateError")

        XCTAssertTrue(
            app.staticTexts["error_message_label"].waitForExistence(timeout: 5)
        )
    }

    func test_newsFeed_showsRetryButton_onFailure() {
        launch(mode: "UITestSimulateError")

        XCTAssertTrue(
            app.buttons["error_retry_button"].waitForExistence(timeout: 5)
        )
    }

    func test_newsFeed_noItemsShown_onFailure() {
        launch(mode: "UITestSimulateError")

        XCTAssertTrue(app.staticTexts["error_message_label"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[items[0]].exists)
    }

    // MARK: - Empty State

    func test_newsFeed_noItemsShown_onEmptyState() {
        launch(mode: "UITestSimulateEmpty")

        XCTAssertFalse(app.staticTexts["error_message_label"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[items[0]].exists)
    }

    func test_newsFeed_noErrorShown_onEmptyState() {
        launch(mode: "UITestSimulateEmpty")

        XCTAssertFalse(app.staticTexts["error_message_label"].waitForExistence(timeout: 5))
    }
}
