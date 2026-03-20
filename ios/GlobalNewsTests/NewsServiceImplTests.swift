
import Testing
import Foundation
@testable import News

@Suite("NewsServiceImplTests")
struct NewsServiceImplTests {

    let session: MockNetworkSession
    let parser: MockRSSParser
    let sut: NewsServiceImpl

    init() {
        session = MockNetworkSession()
        parser = MockRSSParser()
        sut = NewsServiceImpl(networkSession: session, parser: parser)
    }

    // MARK: Success

    @Test("fetchNews returns parsed items on 200 response")
    func fetchNews_success() async throws {
        let dtos = [NewsItemDTO.stub(title: "One"), NewsItemDTO.stub(title: "Two")]
        parser.stubbedItems = dtos
        session.result = .success((Data("<rss/>".utf8), makeHTTPResponse(statusCode: 200)))

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.count == 2)
        #expect(items[0].title == "One")
        #expect(items[1].title == "Two")
    }

    @Test("fetchNews returns empty array when parser returns no items")
    func fetchNews_emptyParse() async throws {
        parser.stubbedItems = []
        session.result = .success((Data("<rss/>".utf8), makeHTTPResponse(statusCode: 200)))

        let items = try await sut.fetchNews(query: .stub())

        #expect(items.isEmpty)
    }

    @Test("fetchNews passes response data to parser")
    func fetchNews_passesDataToParser() async throws {
        let data = Data("<rss>content</rss>".utf8)
        session.result = .success((data, makeHTTPResponse(statusCode: 200)))

        _ = try await sut.fetchNews(query: .stub())

        #expect(parser.receivedData == data)
    }

    // MARK: HTTP Status Codes

    @Test("fetchNews throws notFound on 404")
    func fetchNews_404() async {
        session.result = .success((Data(), makeHTTPResponse(statusCode: 404)))

        await #expect(throws: NewsServiceError.notFound) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews throws serverError on 400")
    func fetchNews_400() async throws {
        session.result = .success((Data(), makeHTTPResponse(statusCode: 400)))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error")
        } catch let error as NewsServiceError {
            if case .clientError(let code) = error {
                #expect(code == 400)
            } else {
                #expect(Bool(false), "Expected .serverError, got \(error)")
            }
        }
    }

    @Test("fetchNews throws serverError on 500")
    func fetchNews_500() async throws {
        session.result = .success((Data(), makeHTTPResponse(statusCode: 500)))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error")
        } catch let error as NewsServiceError {
            if case .serverError(let code) = error {
                #expect(code == 500)
            } else {
                #expect(Bool(false), "Expected .serverError, got \(error)")
            }
        }
    }

    @Test("fetchNews throws serverError on 503")
    func fetchNews_503() async throws {
        session.result = .success((Data(), makeHTTPResponse(statusCode: 503)))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error")
        } catch let error as NewsServiceError {
            if case .serverError(let code) = error {
                #expect(code == 503)
            } else {
                #expect(Bool(false), "Expected .serverError, got \(error)")
            }
        }
    }

    @Test("fetchNews throws invalidResponse when response is not HTTPURLResponse")
    func fetchNews_invalidResponse() async {
        session.result = .success((Data(), URLResponse()))

        await #expect(throws: NewsServiceError.invalidResponse) {
            try await sut.fetchNews(query: .stub())
        }
    }

    // MARK: URLError Mapping

    @Test("fetchNews throws timeout on URLError.timedOut")
    func fetchNews_timeout() async {
        session.result = .failure(URLError(.timedOut))

        await #expect(throws: NewsServiceError.timeout) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews throws networkFailure on URLError.notConnectedToInternet")
    func fetchNews_notConnected() async {
        session.result = .failure(URLError(.notConnectedToInternet))

        await #expect(throws: NewsServiceError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews throws networkFailure on URLError.networkConnectionLost")
    func fetchNews_connectionLost() async {
        session.result = .failure(URLError(.networkConnectionLost))

        await #expect(throws: NewsServiceError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews throws networkFailure on URLError.cannotConnectToHost")
    func fetchNews_cannotConnectToHost() async {
        session.result = .failure(URLError(.cannotConnectToHost))

        await #expect(throws: NewsServiceError.networkFailure) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews rethrows CancellationError on URLError.cancelled")
    func fetchNews_cancelled() async {
        session.result = .failure(URLError(.cancelled))

        await #expect(throws: CancellationError.self) {
            try await sut.fetchNews(query: .stub())
        }
    }

    @Test("fetchNews throws unknown on unrecognised URLError")
    func fetchNews_unknownURLError() async throws {
        session.result = .failure(URLError(.badServerResponse))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error")
        } catch let error as NewsServiceError {
            if case .unknown = error { /* pass */ } else {
                #expect(Bool(false), "Expected .unknown, got \(error)")
            }
        }
    }

    @Test("fetchNews throws unknown on non-URLError")
    func fetchNews_nonURLError() async throws {
        session.result = .failure(NSError(domain: "test", code: -1))

        do {
            _ = try await sut.fetchNews(query: .stub())
            #expect(Bool(false), "Expected error")
        } catch let error as NewsServiceError {
            if case .unknown = error { /* pass */ } else {
                #expect(Bool(false), "Expected .unknown, got \(error)")
            }
        }
    }

    // MARK: URL Construction

    @Test("fetchNews builds correct URL from query")
    func fetchNews_urlConstruction() async throws {
        final class URLCapturingSession: NetworkSession {
            var capturedURL: URL?
            func data(from url: URL) async throws -> (Data, URLResponse) {
                capturedURL = url
                return (Data(), makeHTTPResponse(statusCode: 200))
            }
        }

        let capturingSession = URLCapturingSession()
        let service = await NewsServiceImpl(networkSession: capturingSession, parser: parser)
        let query = await NewsQuery(q: "AI", hl: "fi-FI", gl: "FI")

        _ = try await service.fetchNews(query: query)

        let components = URLComponents(url: capturingSession.capturedURL!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        #expect(components?.host == "news.google.com")
        #expect(queryItems.first(where: { $0.name == "q" })?.value == "AI")
        #expect(queryItems.first(where: { $0.name == "hl" })?.value == "fi-FI")
        #expect(queryItems.first(where: { $0.name == "gl" })?.value == "FI")
        #expect(queryItems.first(where: { $0.name == "ceid" })?.value == "FI:fi")
    }
}

// MARK: - NewsServiceError Equatable

extension NewsServiceError: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl): true
        case (.invalidResponse, .invalidResponse): true
        case (.notFound, .notFound): true
        case (.networkFailure, .networkFailure): true
        case (.timeout, .timeout): true
        case (.clientError(let a), .clientError(let b)): a == b
        case (.serverError(let a), .serverError(let b)): a == b
        case (.unknown, .unknown): true
        default: false
        }
    }
}

// MARK: - Mocks

final class MockNetworkSession: NetworkSession {
    var result: Result<(Data, URLResponse), Error> = .success((Data(), HTTPURLResponse()))

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

final class MockRSSParser: RSSParser {
    var stubbedItems: [NewsItemDTO] = []
    var receivedData: Data?

    func parse(data: Data) -> [NewsItemDTO] {
        receivedData = data
        return stubbedItems
    }
}

// MARK: - Helpers

func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://news.google.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )!
}

func makeSuccessResponse(items: [NewsItemDTO] = [.stub()]) -> (MockRSSParser, Result<(Data, URLResponse), Error>) {
    let data = Data("<rss/>".utf8)
    let response = makeHTTPResponse(statusCode: 200)
    return (MockRSSParser(), .success((data, response)))
}
