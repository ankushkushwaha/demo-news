import Foundation

protocol NewsService {
    func fetchNews(query: NewsQuery) async throws -> [NewsItemDTO]
}

final class NewsServiceImpl: NewsService {

    private let networkSession: NetworkSession
    private let parser: RSSParser

    init(
        networkSession: NetworkSession = URLSession.shared,
        parser: RSSParser = GoogleNewsRSSParser()
    ) {
        self.networkSession = networkSession
        self.parser = parser
    }

    func fetchNews(query: NewsQuery) async throws -> [NewsItemDTO] {
        guard let url = EndPoints.newsFeed(query).url else {
            throw NewsServiceError.invalidUrl
        }

        do {
            let (data, response) = try await networkSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsServiceError.invalidResponse
            }
            
            try validateHTTPResponse(httpResponse.statusCode)
            
            return parser.parse(data: data)
        } catch let error as URLError {
            throw map(error)
        } catch {
            throw NewsServiceError.unknown(error)
        }
    }

    private func map(_ error: URLError) -> any Error {
        switch error.code {
        case .timedOut:
            return NewsServiceError.timeout
        case .cancelled:
            return CancellationError()
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed,
             .internationalRoamingOff,
             .callIsActive:
            return NewsServiceError.networkFailure
        default:
            return NewsServiceError.unknown(error)
        }
    }
    private func validateHTTPResponse(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return
        case 404:
            throw NewsServiceError.notFound
        case 400...499:
            throw NewsServiceError.serverError(statusCode)
        default:
            throw NewsServiceError.serverError(statusCode)
        }
    }
}

enum NewsServiceError: Error {
    case invalidUrl
    case invalidResponse
    case notFound
    case clientError(Int)
    case serverError(Int)
    case networkFailure
    case timeout
    case unknown(Error)
}
