import Combine
import Foundation


protocol BookmarkStore {
    var publisher: AnyPublisher<Set<NewsItem>, Never> { get }
    func toggle(_ item: NewsItem) async
}

final class PersistentBookmarkStore: BookmarkStore {

    private let key: String
    private let defaults: UserDefaults
    private let subject: CurrentValueSubject<Set<NewsItem>, Never>
    var publisher: AnyPublisher<Set<NewsItem>, Never> {
        subject.eraseToAnyPublisher()
    }

    init(key: String = "bookmarks", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
        self.subject = CurrentValueSubject(Self.load(key: key, defaults: defaults))
    }

    private static func load(key: String, defaults: UserDefaults) -> Set<NewsItem> {
        guard
            let data = defaults.data(forKey: key),
            let items = try? JSONDecoder().decode(Set<NewsItem>.self, from: data)
        else { return [] }
        return items
    }
    
    private func save(_ items: Set<NewsItem>) async {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
        subject.send(items)
    }

    func toggle(_ item: NewsItem) async {
        var current = subject.value
        if current.contains(item) {
            current.remove(item)
        } else {
            current.insert(item)
        }
        await save(current)
    }
}

