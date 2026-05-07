import Combine
import Foundation

protocol BookmarkStore {
    var publisher: AnyPublisher<[NewsItem], Never> { get }
    func toggle(_ item: NewsItem) async throws
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
        self.subject = CurrentValueSubject(
            (try? Self.load(key: key, defaults: defaults)) ?? []
        )
    }

    func toggle(_ item: NewsItem) async throws {
        var current = subject.value
        let isRemoving = current.contains(item)
        
        if isRemoving {
            current.remove(at: current.firstIndex(of: item)!)
        } else {
            current.insert(item, at: 0)
        }
        
        do {
            let data = try JSONEncoder().encode(current)
            defaults.set(data, forKey: key)
            subject.send(current)
        } catch {
            if isRemoving {
                throw BookmarkStoreError.removeBookmarkFailed
            } else {
                throw BookmarkStoreError.addBookmarkFailed
            }
        }
    }

    private static func load(key: String, defaults: UserDefaults) throws -> [NewsItem] {
        guard let data = defaults.data(forKey: key) else { return [] }

        do {
            return try JSONDecoder().decode([NewsItem].self, from: data)
        } catch {
            throw BookmarkStoreError.decodingFailed
        }
    }
}

enum BookmarkStoreError: Error {
    case addBookmarkFailed
    case removeBookmarkFailed
    case decodingFailed
}
