import Foundation

enum EndPoints {
    case search(NewsQuery)
    case all
    
    var url: URL? {
        switch self {
        case .all:
            return URL(string: Self.baseUrl + path)

        case .search(let query):
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
        case .all:
            "rss"
        case .search:
            "rss/search"
        }
    }

    private static let baseUrl = "https://news.google.com/"
}
