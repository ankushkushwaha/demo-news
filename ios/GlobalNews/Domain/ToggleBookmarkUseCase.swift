//
//  ToggleBookmarkUseCase.swift
//  GlobalNews
//
//  Created by Ankush on 14.3.2026.
//

protocol ToggleBookmarkUseCase: Sendable {
    func execute(item: NewsItem) async
}

final class ToggleBookmarkUseCaseImpl: ToggleBookmarkUseCase {
    private let repository: BookmarkRepository

    init(repository: BookmarkRepository) {
        self.repository = repository
    }

    func execute(item: NewsItem) async {
        await repository.toggle(item)
    }
}
