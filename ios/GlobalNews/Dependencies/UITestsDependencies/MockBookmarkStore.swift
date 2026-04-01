//
//  MockBookmarkStore.swift
//  News
//
//  Created by Ankush on 20.3.2026.
//


import Combine

extension AppStates {
    static func makeForUITests() -> AppStates {
        AppStates(bookmarkStore: MockBookmarkStore())
    }
}

// MockBookmarkStore.swift
final class MockBookmarkStore: BookmarkStore {

    private let subject = CurrentValueSubject<Set<NewsItem>, Never>([])

    var publisher: AnyPublisher<Set<NewsItem>, Never> {
        subject.eraseToAnyPublisher()
    }

    func toggle(_ item: NewsItem) async {
        var current = subject.value
        if current.contains(item) {
            current.remove(item)
        } else {
            current.insert(item)
        }
        subject.send(current)
    }
}
