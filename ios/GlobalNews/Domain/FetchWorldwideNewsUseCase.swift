
import Foundation
protocol FetchWorldwideNewsUseCase {
    func execute() async throws -> [NewsItem]
}

final class FetchWorldwideNewsUseCaseImpl: FetchWorldwideNewsUseCase {

    private let newsRepository: NewsRepository
    private let analyticsService: AnalyticsService

    init(newsRepository: NewsRepository,
         analyticsService: AnalyticsService
    ) {
        self.newsRepository = newsRepository
        self.analyticsService = analyticsService
    }

    func execute() async throws -> [NewsItem] {
        do {
            let items = try await newsRepository.fetchAllNews()

            analyticsService.sendEvent("FETCHED_WORLDWIDE_NEWS", params: [])

            return items.sorted { $0.pubDate > $1.pubDate }

        } catch {
            analyticsService.sendEvent("FETCHED_WORLDWIDE_NEWS_ERROR", params: [error.localizedDescription])
            throw error
        }
    }
}
