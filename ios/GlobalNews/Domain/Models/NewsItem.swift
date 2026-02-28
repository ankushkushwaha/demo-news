struct NewsItem: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let source: String
    let pubDate: String
    let link: String
    let description: String

    init(
        title: String,
        source: String,
        pubDate: String,
        link: String,
        description: String
    ) {
        self.id = link
        self.title = title
        self.source = source
        self.pubDate = pubDate
        self.link = link
        self.description = description
    }
}
