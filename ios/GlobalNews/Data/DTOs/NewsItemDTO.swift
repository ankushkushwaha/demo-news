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

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    func toNewsItem() -> NewsItem {
        let date = Self.dateFormatter.date(from: pubDate) ?? .distantPast
        let displayString = date == .distantPast
            ? pubDate
            : Self.relativeFormatter.localizedString(for: date, relativeTo: Date())

        return NewsItem(
            id: guid,
            title: title,
            source: source,
            pubDate: date,
            pubDateString: displayString,
            link: link,
            description: description
        )
    }
}
