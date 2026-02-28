
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
