//
//  Mocks.swift
//  GlobalNewsTests
//
//  Created by Ankush on 18.3.2026.
//

import Foundation
import Combine
@testable import News

final class MockFetchNewsUseCase: FetchTopicNewsUseCase {
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
    private let subject = CurrentValueSubject<[NewsItem], Never>([])

    var publisher: AnyPublisher<[NewsItem], Never> {
        subject.eraseToAnyPublisher()
    }

    func emit(_ items: [NewsItem]) {
        subject.send(items)
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


extension NewsItem {
    static func stub(
        id: String = "https://example.com",
        title: String = "Title",
        source: String = "Source",
        pubDate: Date = Date(),
        pubDateString: String = "1 hour ago",
        link: String = "https://example.com",
        description: String = "Description"
    ) -> NewsItem {
        NewsItem(
            id: id,
            title: title,
            source: source,
            pubDate: pubDate,
            pubDateString: pubDateString,
            link: link,
            description: description
        )
    }
}

func makeNewsItem(
    title: String = "Title",
    link: String = "https://example.com",
    pubDate: Date = Date(),
    pubDateString: String = "1 hour ago"
) -> NewsItem {
    NewsItem(
        id: UUID().uuidString,
        title: title,
        source: "",
        pubDate: pubDate,
        pubDateString: pubDateString,
        link: link,
        description: ""
    )
}
