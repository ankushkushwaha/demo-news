//
//  BookmarkRepositoryImpl.swift
//  GlobalNews
//
//  Created by Ankush on 14.3.2026.
//

import Combine

protocol BookmarkRepository {
    var bookmarksPublisher: AnyPublisher<Set<NewsItem>, Never> { get }
    func toggle(_ item: NewsItem) async
}

final class BookmarkRepositoryImpl: BookmarkRepository {

    private let store: BookmarkStore

    init(store: BookmarkStore) {
        self.store = store
    }

    func toggle(_ item: NewsItem) async {
        await store.toggle(item)
    }

    var bookmarksPublisher: AnyPublisher<Set<NewsItem>, Never> {
        store.publisher
    }
}
