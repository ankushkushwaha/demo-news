import Foundation

struct NewsItem: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let source: String
    let pubDate: Date
    let pubDateString: String
    let link: String
    let description: String

    init(
        id: String,
        title: String,
        source: String,
        pubDate: Date,
        pubDateString: String,
        link: String,
        description: String
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.pubDate = pubDate
        self.pubDateString = pubDateString
        self.link = link
        self.description = description
    }
}
