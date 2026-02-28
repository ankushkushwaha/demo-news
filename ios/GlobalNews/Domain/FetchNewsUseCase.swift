import Combine

protocol FetchNewsUseCase {
    func execute(topic: String?, location: UserLocation?) async throws -> [NewsItem]
}

final class FetchNewsUseCaseImpl: FetchNewsUseCase {
    
    private let newsRepository: NewsRepository

    init(
        newsRepository: NewsRepository = NewsRepositoryImpl(),
    ) {
        self.newsRepository = newsRepository
    }
        
    func execute(topic: String?, location: UserLocation?) async throws -> [NewsItem] {
        let query = NewsQuery(
            q:  topic ?? location?.countryName ?? "world",
            hl: location?.hl ?? "en-US",
            gl: location?.gl ?? "US"
        )
        return try await newsRepository.fetchNews(query: query)
    }
}
