
protocol FetchAllNewsUseCase {
    func execute() async throws -> [NewsItem]
}

final class FetchAllNewsUseCaseImpl: FetchAllNewsUseCase {

    private let newsRepository: NewsRepository

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    func execute() async throws -> [NewsItem] {
        return try await newsRepository.fetchAllNews()
    }
}
