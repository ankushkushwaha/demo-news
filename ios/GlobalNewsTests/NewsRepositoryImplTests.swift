
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

    // MARK: Success

    @Test("fetchNews returns mapped NewsItems on success")
    func fetchNews_success() async throws {
        let dtos = [NewsItemDTO.stub(title: "One"), NewsItemDTO.stub(title: "Two")]
        service.result = .success(dtos)

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.count == 2)
        #expect(items[0].title == "One")
        #expect(items[1].title == "Two")
    }

    @Test("fetchNews returns empty array when service returns no items")
    func fetchNews_emptyResult() async throws {
        service.result = .success([])

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.isEmpty)
    }

    // MARK: Error Mapping

    @Test("fetchNews maps invalidUrl to invalidRequest")
    func fetchNews_invalidUrl() async {
        service.result = .failure(NewsServiceError.invalidUrl)

        await #expect(throws: NewsRepositoryError.invalidRequest) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps clientError to invalidRequest")
    func fetchNews_clientError() async {
        service.result = .failure(NewsServiceError.clientError(400))

        await #expect(throws: NewsRepositoryError.invalidRequest) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps invalidResponse to networkFailure")
    func fetchNews_invalidResponse() async {
        service.result = .failure(NewsServiceError.invalidResponse)

        await #expect(throws: NewsRepositoryError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps networkFailure to networkFailure")
    func fetchNews_networkFailure() async {
        service.result = .failure(NewsServiceError.networkFailure)

        await #expect(throws: NewsRepositoryError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps timeout to timeout")
    func fetchNews_timeout() async {
        service.result = .failure(NewsServiceError.timeout)

        await #expect(throws: NewsRepositoryError.timeout) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps notFound to notFound")
    func fetchNews_notFound() async {
        service.result = .failure(NewsServiceError.notFound)

        await #expect(throws: NewsRepositoryError.notFound) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews maps serverError to serverError preserving code")
    func fetchNews_serverError() async throws {
        service.result = .failure(NewsServiceError.serverError(503))

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
        service.result = .failure(NewsServiceError.unknown(underlying))

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
        service.result = .failure(underlying)

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

    // MARK: Cancellation

    @Test("fetchNews rethrows CancellationError without wrapping")
    func fetchNews_cancellation() async {
        service.result = .failure(CancellationError())

        await #expect(throws: CancellationError.self) {
            try await sut.fetchNews(query: .stub())
        }
    }

    // MARK: Query passthrough

    @Test("fetchNews passes query to service unchanged")
    func fetchNews_passesQueryToService() async throws {
        final class QueryCapturingService: NewsService {
            var capturedQuery: NewsQuery?
            func fetchNews(query: NewsQuery) async throws -> [NewsItemDTO] {
                capturedQuery = query
                return []
            }
        }

        let capturingService = QueryCapturingService()
        let repo = await NewsRepositoryImpl(service: capturingService)
        let query = NewsQuery(q: "AI", hl: "fi-FI", gl: "FI")

        _ = try await repo.fetchNews(query: query)

        #expect(capturingService.capturedQuery?.q == "AI")
        #expect(capturingService.capturedQuery?.hl == "fi-FI")
        #expect(capturingService.capturedQuery?.gl == "FI")
        #expect(capturingService.capturedQuery?.ceid == "FI:fi")
    }
}

// MARK: - Mock

extension NewsRepositoryError: Equatable {
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
    var result: Result<[NewsItemDTO], Error> = .success([])

    func fetchNews(query: NewsQuery) async throws -> [NewsItemDTO] {
        try result.get()
    }
}

// MARK: - Stubs

extension NewsItemDTO {
    static func stub(
        title: String = "Title",
        source: String = "Source",
        pubDate: String = "1.1.2026",
        link: String = "https://example.com",
        description: String = "Description"
    ) -> NewsItemDTO {
        NewsItemDTO(
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

