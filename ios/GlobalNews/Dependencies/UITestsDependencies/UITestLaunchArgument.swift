
final class MockEmptyNewsService: NewsService {

    func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
        []
    }

    func fetchAllNews() async throws -> [NewsItemDTO] {
        []
    }
}

