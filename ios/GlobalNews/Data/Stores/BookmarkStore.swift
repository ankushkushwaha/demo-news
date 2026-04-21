import Combine
import Foundation

protocol BookmarkStore {
    var publisher: AnyPublisher<[NewsItem], Never> { get }
    func toggle(_ item: NewsItem) async
}

final class PersistentBookmarkStore: BookmarkStore {

    private let key: String
    private let defaults: UserDefaults
    private let subject: CurrentValueSubject<[NewsItem], Never>

    var publisher: AnyPublisher<[NewsItem], Never> {
        subject.eraseToAnyPublisher()
    }

    init(key: String = "bookmarks", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
        self.subject = CurrentValueSubject(Self.load(key: key, defaults: defaults))
    }

    private static func load(key: String, defaults: UserDefaults) -> [NewsItem] {
        guard
            let data = defaults.data(forKey: key),
            let items = try? JSONDecoder().decode([NewsItem].self, from: data)
        else { return [] }
        return items
    }

    private func save(_ items: [NewsItem]) async {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
        subject.send(items)
    }

    func toggle(_ item: NewsItem) async {
        var current = subject.value
        if let index = current.firstIndex(of: item) {
            current.remove(at: index)
        } else {
            current.insert(item, at: 0)
        }
        await save(current)
    }
}
