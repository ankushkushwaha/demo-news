
protocol FetchWorldwideNewsUseCase {
    func execute() async throws -> [NewsItem]
}

final class FetchWorldwideNewsUseCaseImpl: FetchWorldwideNewsUseCase {

    private let newsRepository: NewsRepository

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    func execute() async throws -> [NewsItem] {
        let items =  try await newsRepository.fetchAllNews()
        return items.sorted { $0.pubDate > $1.pubDate }
    }
}
