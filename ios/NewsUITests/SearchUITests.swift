//
//  SearchUITests.swift
//  News
//
//  Created by Ankush on 21.3.2026.
//


import XCTest

final class SearchUITests: XCTestCase {

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

    private func launch(mode: String = "UITestSimulateSuccess") {
        app.launchArguments = [mode]
        app.launch()
    }

    private func goToSearchTab() {
        app.buttons.matching(NSPredicate(format: "label == 'Search'")).firstMatch.tap()
    }

    private func goToBookmarksTab() {
        app.buttons.matching(NSPredicate(format: "label == 'Bookmarks'")).firstMatch.tap()
    }

    private func typeQuery(_ query: String) {
        let field = app.textFields["search_text_field"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.tap()
        field.typeText(query)
        // Wait for SwiftUI to re-render after text change
        sleep(1)
    }

    // MARK: - Layout

    func test_search_showsSearchField() {
        launch()
        goToSearchTab()

        XCTAssertTrue(
            app.textFields["search_text_field"].waitForExistence(timeout: 3)
        )
    }

    func test_search_noClearButton_initially() {
        launch()
        goToSearchTab()

        XCTAssertFalse(app.buttons["search_clear_button"].exists)
    }

    func test_search_showsClearButton_afterTyping() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(
            app.buttons["search_clear_button"].waitForExistence(timeout: 3)
        )
    }
    
    func test_search_clearButton_clearsField() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        app.buttons["search_clear_button"].tap()
        sleep(1)

        let fieldValue = app.textFields["search_text_field"].value as? String ?? ""
        XCTAssertEqual(fieldValue, "Search news...", "Expected placeholder after clearing")
        XCTAssertFalse(app.buttons["search_clear_button"].exists)
    }
    
    // MARK: - Success

    func test_search_showsResults_afterTypingQuery() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(
            app.staticTexts[firstTitle].waitForExistence(timeout: 3)
        )
    }

    func test_search_showsAllResults() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts[secondTitle].exists)
        XCTAssertTrue(app.staticTexts[thirdTitle].exists)
    }

    func test_search_showsSourceForFirstResult() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(
            app.staticTexts[firstTitle].waitForExistence(timeout: 3)
        )
    }

    // MARK: - Empty State

    func test_search_showsEmptyPrompt_whenNoResults() {
        launch(mode: "UITestSimulateEmpty")
        goToSearchTab()
        typeQuery("xyzzy")

        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "identifier == 'search_empty_prompt' AND label != ''"))
                .firstMatch
                .waitForExistence(timeout: 3)
        )
    }

    func test_search_noItems_whenNoResults() {
        launch(mode: "UITestSimulateEmpty")
        goToSearchTab()
        typeQuery("xyzzy")

        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "identifier == 'search_empty_prompt' AND label != ''"))
                .firstMatch
                .waitForExistence(timeout: 3)
        )
        XCTAssertFalse(app.staticTexts[firstTitle].exists)
    }

    // MARK: - Error

    func test_search_showsErrorPrompt_onFailure() {
        launch(mode: "UITestSimulateError")
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "identifier == 'search_empty_prompt' AND label != ''"))
                .firstMatch
                .waitForExistence(timeout: 3)
        )
    }

    func test_search_noItems_onFailure() {
        launch(mode: "UITestSimulateError")
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "identifier == 'search_empty_prompt' AND label != ''"))
                .firstMatch
                .waitForExistence(timeout: 3)
        )
        XCTAssertFalse(app.staticTexts[firstTitle].exists)
    }
    // MARK: - Clear resets results

    func test_search_clearingQuery_hidesResults() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))

        app.buttons["search_clear_button"].tap()

        XCTAssertFalse(app.staticTexts[firstTitle].waitForExistence(timeout: 2))
    }

    // MARK: - Bookmark from Search

    func test_search_bookmarkButton_exists_onResult() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))

        XCTAssertTrue(
            app.buttons["Add bookmark"].waitForExistence(timeout: 3)
        )
    }

    func test_search_bookmarkedItem_appearsInBookmarksTab() {
        launch()
        goToSearchTab()
        typeQuery("Swift")

        XCTAssertTrue(app.staticTexts[firstTitle].waitForExistence(timeout: 3))
        app.buttons["Add bookmark"].firstMatch.tap()

        goToBookmarksTab()

        XCTAssertTrue(
            app.staticTexts[firstTitle].waitForExistence(timeout: 3)
        )
    }
}
