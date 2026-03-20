//
//  Mocks.swift
//  GlobalNewsTests
//
//  Created by Ankush on 18.3.2026.
//

import Foundation
import Combine
@testable import News

final class MockFetchNewsUseCase: FetchNewsUseCase {
    var newsItems: [NewsItem]?
    var error: Error?
    private(set) var callCount = 0
    private(set) var capturedLocation: UserLocation?

    func execute(topic: String?, location: UserLocation?) async throws -> [NewsItem] {
        callCount += 1
        capturedLocation = location
                
        if let error {
            throw error
        }
        return newsItems!
    }
}

final class MockToggleBookmarkUseCase: ToggleBookmarkUseCase, @unchecked Sendable {
    private(set) var callCount = 0
    private(set) var capturedItem: NewsItem?

    func execute(item: NewsItem) async {
        callCount += 1
        capturedItem = item
    }
}

final class MockObserveBookmarksUseCase: ObserveBookmarksUseCase {
    private let subject = CurrentValueSubject<Set<NewsItem>, Never>([])

    var publisher: AnyPublisher<Set<NewsItem>, Never> {
        subject.eraseToAnyPublisher()
    }

    func emit(_ value: Set<NewsItem>) {
        subject.send(value)
    }
}

final class MockObserveLocationUseCase: ObserveLocationUseCase {
    
    private let subject = PassthroughSubject<Result<UserLocation, LocationRepositoryError>, Never>()

    var locationUpdatePublisher: AnyPublisher<Result<UserLocation, LocationRepositoryError>, Never> {
        subject.eraseToAnyPublisher()
    }
    private(set) var attemptCallCount = 0

    func attemptToGetLocation() async {
        attemptCallCount += 1
    }

    func emit(_ location: UserLocation) {
        subject.send(.success(location))
    }
    
    // Fixed: only accept LocationRepositoryError
    func emitError(_ error: LocationRepositoryError) {
        subject.send(.failure(error))
    }
}


// MARK: - Helpers

private func makeLocation(
    countryCode: String = "DE",
    countryName: String = "Germany",
    city: String = "Berlin",
    languageCode: String = "de"
) -> UserLocation {
    UserLocation(
        countryCode: countryCode,
        countryName: countryName,
        city: city,
        languageCode: languageCode
    )
}

func makeNewsItem(
    title: String = "Title",
    link: String = "https://example.com"
) -> NewsItem {
    NewsItem(title: title, source: "", pubDate: "1.1.2026", link: link, description: "")
}
