import Foundation

struct NewsItemDTO {
    let title: String
    let source: String
    let pubDate: String
    let link: String
    let description: String
}

extension NewsItemDTO {
    func toNewsItem() -> NewsItem {
        NewsItem(
            title: title,
            source: source,
            pubDate: pubDate,
            link: link,
            description: description,
        )
    }
}

struct NewsQuery {
    let q: String
    let hl: String
    let gl: String
    var ceid: String { "\(gl):\(String(hl.prefix(2)))" }
    
    init(q: String, hl: String = "en-US", gl: String = "US") {
        self.q = q
        self.hl = hl
        self.gl = gl
    }
}

// MARK: - Endpoints

enum EndPoints {
    case newsFeed(NewsQuery)

    var url: URL? {
        switch self {
        case .newsFeed(let query):
            var components = URLComponents(string: Self.baseUrl + path)
            components?.queryItems = [
                URLQueryItem(name: "q", value: query.q),
                URLQueryItem(name: "hl", value: query.hl),
                URLQueryItem(name: "gl", value: query.gl),
                URLQueryItem(name: "ceid", value: query.ceid)
            ]
            return components?.url
        }
    }

    private var path: String {
        switch self {
        case .newsFeed: return "rss/search"
        }
    }

    private static let baseUrl = "https://news.google.com/"
}

// MARK: - Errors

enum NewsServiceError: Error {
    case invalidUrl
    case invalidResponse
    case httpError(Int)
}


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

        let (data, response) = try await networkSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsServiceError.invalidResponse
        }

        try validateResponse(httpResponse)
        
        return parser.parse(data: data)
    }

    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        default:
            throw NewsServiceError.httpError(response.statusCode)
        }
    }
}

// MARK: - NetworkSession

protocol NetworkSession {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
