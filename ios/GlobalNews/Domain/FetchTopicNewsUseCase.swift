import Combine

protocol FetchTopicNewsUseCase {
    func execute(topic: String?, location: UserLocation?) async throws -> [NewsItem]
}

final class FetchTopicNewsUseCaseImpl: FetchTopicNewsUseCase {
    
    private let newsRepository: NewsRepository

    init(
        newsRepository: NewsRepository
    ) {
        self.newsRepository = newsRepository
    }
        
    func execute(topic: String?, location: UserLocation?) async throws -> [NewsItem] {
        let query = NewsQuery(
            q:  topic ?? location?.countryName ?? "world",
            hl: location?.hl ?? "en-US",
            gl: location?.gl ?? "US"
        )
        let items = try await newsRepository.fetchNews(query: query)
        return items.sorted { $0.pubDate > $1.pubDate }
    }
}
