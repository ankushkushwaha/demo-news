#if DEBUG

final class MockNewsService: NewsService {

    static let stubbedItems: [NewsItemDTO] = [
        NewsItemDTO(
            title: "Swift 6 Concurrency Deep Dive",
            source: "Swift Weekly",
            pubDate: "20 Mar 2026",
            link: "https://example.com/1",
            description: "Everything you need to know about Swift 6."
        ),
        NewsItemDTO(
            title: "Apple Vision Pro 2 Announced",
            source: "Tech Crunch",
            pubDate: "19 Mar 2026",
            link: "https://example.com/2",
            description: "Apple unveils the next generation of spatial computing."
        ),
        NewsItemDTO(
            title: "SwiftUI Performance Tips",
            source: "Hacking with Swift",
            pubDate: "18 Mar 2026",
            link: "https://example.com/3",
            description: "Practical techniques to speed up your SwiftUI apps."
        )
    ]

    func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
        MockNewsService.stubbedItems
    }

    func fetchAllNews() async throws -> [NewsItemDTO] {
        MockNewsService.stubbedItems
    }
}

final class MockFailingNewsService: NewsService {

    func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
        throw NewsServiceError.networkFailure
    }

    func fetchAllNews() async throws -> [NewsItemDTO] {
        throw NewsServiceError.networkFailure
    }
}


final class MockEmptyNewsService: NewsService {

    func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
        []
    }

    func fetchAllNews() async throws -> [NewsItemDTO] {
        []
    }
}

#endif
