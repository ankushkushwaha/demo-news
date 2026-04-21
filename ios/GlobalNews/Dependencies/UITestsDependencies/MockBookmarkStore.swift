#if DEBUG

import Combine

extension AppStates {
    static func makeForUITests() -> AppStates {
        AppStates(bookmarkStore: MockBookmarkStore())
    }
}

final class MockBookmarkStore: BookmarkStore {

    private let subject = CurrentValueSubject<[NewsItem], Never>([])

    var publisher: AnyPublisher<[NewsItem], Never> {
        subject.eraseToAnyPublisher()
    }

    func toggle(_ item: NewsItem) async {
        var current = subject.value
        if let index = current.firstIndex(of: item) {
            current.remove(at: index)
        } else {
            current.insert(item, at: 0)
        }
        subject.send(current)
    }
}
#endif
