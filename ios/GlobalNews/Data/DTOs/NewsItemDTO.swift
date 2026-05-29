import Foundation

struct NewsItemDTO {
    let guid: String
    let title: String
    let source: String
    let pubDate: String
    let link: String
    let description: String
}

extension NewsItemDTO {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return formatter
    }()

    func toNewsItem() -> NewsItem {
        let date = Self.dateFormatter.date(from: pubDate) ?? .distantPast
        return NewsItem(
            id: guid,
            title: title,
            source: source,
            pubDate: date,
            link: link,
            description: description
        )
    }
}
