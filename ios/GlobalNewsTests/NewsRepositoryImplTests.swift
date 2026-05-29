import Testing
import Foundation
@testable import News

@Suite("NewsRepositoryImpl")
struct NewsRepositoryImplTests {

    let service: MockNewsService
    let sut: NewsRepositoryImpl

    init() {
        service = MockNewsService()
        sut = NewsRepositoryImpl(service: service)
    }

    @Test("fetchNews returns mapped NewsItems on success")
    func fetchNews_success() async throws {
        let dtos = [NewsItemDTO.stub(title: "One"), NewsItemDTO.stub(title: "Two")]
        service.fetchNewsResult = .success(dtos)

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.count == 2)
        #expect(items[0].title == "One")
        #expect(items[1].title == "Two")
    }

    @Test("fetchNews returns empty array when service returns no items")
    func fetchNews_emptyResult() async throws {
        service.fetchNewsResult = .success([])

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.isEmpty)
    }

    // MARK: Error Mapping

    @Test("fetchNews maps invalidUrl to invalidRequest")
    func fetchNews_invalidUrl() async {
        service.fetchNewsResult = .failure(NewsServiceError.invalidUrl)

        await #expect(throws: NewsRepositoryError.invalidRequest) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps clientError to invalidRequest")
    func fetchNews_clientError() async {
        service.fetchNewsResult = .failure(NewsServiceError.clientError(400))

        await #expect(throws: NewsRepositoryError.invalidRequest) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps invalidResponse to networkFailure")
    func fetchNews_invalidResponse() async {
        service.fetchNewsResult = .failure(NewsServiceError.invalidResponse)

        await #expect(throws: NewsRepositoryError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps networkFailure to networkFailure")
    func fetchNews_networkFailure() async {
        service.fetchNewsResult = .failure(NewsServiceError.networkFailure)

        await #expect(throws: NewsRepositoryError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps timeout to timeout")
    func fetchNews_timeout() async {
        service.fetchNewsResult = .failure(NewsServiceError.timeout)

        await #expect(throws: NewsRepositoryError.timeout) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps notFound to notFound")
    func fetchNews_notFound() async {
        service.fetchNewsResult = .failure(NewsServiceError.notFound)

        await #expect(throws: NewsRepositoryError.notFound) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps serverError to serverError preserving code")
    func fetchNews_serverError() async throws {
        service.fetchNewsResult = .failure(NewsServiceError.serverError(503))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error to be thrown")
        } catch let error as NewsRepositoryError {
            if case .serverError(let code) = error {
                #expect(code == 503)
            } else {
                #expect(Bool(false), "Expected .serverError, got \(error)")
            }
        }
    }

    @Test("fetchNews maps unknown service error to unknown repository error")
    func fetchNews_unknownServiceError() async throws {
        let underlying = NSError(domain: "test", code: -1)
        service.fetchNewsResult = .failure(NewsServiceError.unknown(underlying))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error to be thrown")
        } catch let error as NewsRepositoryError {
            if case .unknown = error {
                // pass
            } else {
                #expect(Bool(false), "Expected .unknown, got \(error)")
            }
        }
    }

    @Test("fetchNews maps unknown non-service error to unknown repository error")
    func fetchNews_unknownNonServiceError() async throws {
        let underlying = NSError(domain: "unexpected", code: 99)
        service.fetchNewsResult = .failure(underlying)

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error to be thrown")
        } catch let error as NewsRepositoryError {
            if case .unknown = error {
                // pass
            } else {
                #expect(Bool(false), "Expected .unknown, got \(error)")
            }
        }
    }

    @Test("fetchNews rethrows CancellationError without wrapping")
    func fetchNews_cancellation() async {
        service.fetchNewsResult = .failure(CancellationError())

        await #expect(throws: CancellationError.self) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews passes query to service unchanged")
    func fetchNews_passesQueryToService() async throws {
        final class QueryCapturingService: NewsService {
            var capturedQuery: NewsQuery?

            func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
                capturedQuery = query
                return []
            }

            func fetchAllNews() async throws -> [NewsItemDTO] { [] }
        }

        let capturingService = QueryCapturingService()
        let repo = await NewsRepositoryImpl(service: capturingService)
        let query = await NewsQuery(q: "AI", hl: "fi-FI", gl: "FI")

        _ = try await repo.fetchNews(query: query)

        #expect(capturingService.capturedQuery?.q == "AI")
        #expect(capturingService.capturedQuery?.hl == "fi-FI")
        #expect(capturingService.capturedQuery?.gl == "FI")
        #expect(capturingService.capturedQuery?.ceid == "FI:fi")
    }

    @Test("fetchAllNews returns mapped NewsItems on success")
    func fetchAllNews_success() async throws {
        let dtos = [NewsItemDTO.stub(title: "All One"), NewsItemDTO.stub(title: "All Two")]
        service.fetchAllNewsResult = .success(dtos)

        let items = try await sut.fetchAllNews()

        #expect(items.count == 2)
        #expect(items[0].title == "All One")
        #expect(items[1].title == "All Two")
    }

    @Test("fetchAllNews returns empty array when service returns no items")
    func fetchAllNews_emptyResult() async throws {
        service.fetchAllNewsResult = .success([])

        let items = try await sut.fetchAllNews()

        #expect(items.isEmpty)
    }

    @Test("fetchAllNews maps networkFailure to networkFailure")
    func fetchAllNews_networkFailure() async {
        service.fetchAllNewsResult = .failure(NewsServiceError.networkFailure)

        await #expect(throws: NewsRepositoryError.networkFailure) {
            try await sut.fetchAllNews()
        }
    }

    @Test("fetchAllNews rethrows CancellationError without wrapping")
    func fetchAllNews_cancellation() async {
        service.fetchAllNewsResult = .failure(CancellationError())

        await #expect(throws: CancellationError.self) {
            try await sut.fetchAllNews()
        }
    }
}

// MARK: - Mocks

extension NewsRepositoryError: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest): true
        case (.networkFailure, .networkFailure): true
        case (.timeout, .timeout): true
        case (.notFound, .notFound): true
        case (.serverError(let a), .serverError(let b)): a == b
        case (.unknown, .unknown): true
        default: false
        }
    }
}

final class MockNewsService: NewsService {
    var fetchNewsResult: Result<[NewsItemDTO], Error> = .success([])
    var fetchAllNewsResult: Result<[NewsItemDTO], Error> = .success([])

    func fetchNews(for query: NewsQuery) async throws -> [NewsItemDTO] {
        try fetchNewsResult.get()
    }

    func fetchAllNews() async throws -> [NewsItemDTO] {
        try fetchAllNewsResult.get()
    }
}

extension NewsItemDTO {
    static func stub(
        title: String = "Title",
        source: String = "Source",
        pubDate: String = "1.1.2026",
        link: String = "https://example.com",
        description: String = "Description"
    ) -> NewsItemDTO {
        NewsItemDTO(
            guid: UUID().uuidString,
            title: title,
            source: source,
            pubDate: pubDate,
            link: link,
            description: description
        )
    }
}

extension NewsQuery {
    static func stub(
        q: String = "swift",
        hl: String = "en-US",
        gl: String = "US"
    ) -> NewsQuery {
        NewsQuery(q: q, hl: hl, gl: gl)
    }
}
