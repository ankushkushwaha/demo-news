import Foundation

// MARK: - Models

// MARK: - Parser

protocol RSSParser {
    func parse(data: Data) -> [NewsItemDTO]
}

final class GoogleNewsRSSParser: NSObject, RSSParser, XMLParserDelegate {

    // MARK: Static reused objects
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return f
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    // MARK: Parser state
    private var items: [NewsItemDTO] = []
    private var currentElement = ""
    private var currentItem: ParsedItem?
    private var isInChannelImage = false

    func parse(data: Data) -> [NewsItemDTO] {
        items.removeAll(keepingCapacity: true)
        currentItem = nil
        currentElement = ""
        isInChannelImage = false

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {

        currentElement = elementName

        switch elementName {

        // Channel-level <image> block — skip its child <title>/<link>
        case "image" where currentItem == nil:
            isInChannelImage = true

        case "item":
            isInChannelImage = false
            currentItem = ParsedItem()

        // <source url="https://...">Publisher Name</source>
        case "source":
            currentItem?.sourceURL = attributeDict["url"] ?? ""

        // <media:content url="..." medium="image"/>
        // qualifiedName == "media:content"
        case "content" where qName?.hasPrefix("media:") == true:
            if let url = attributeDict["url"], !url.isEmpty {
                currentItem?.imageURL = url
            }

        // <enclosure url="..." type="image/jpeg"/>
        case "enclosure":
            if let url = attributeDict["url"], !url.isEmpty {
                currentItem?.imageURL = url
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let item = currentItem, !isInChannelImage else { return }

        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch currentElement {
        case "title":       item.title       += trimmed
        case "link":        item.link        += trimmed
        case "pubDate":     item.pubDate     += trimmed
        case "description": item.description += trimmed
        case "source":      item.sourceName  += trimmed
        default: break
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        defer { currentElement = "" }

        if elementName == "image" && currentItem == nil {
            isInChannelImage = false
            return
        }

        guard elementName == "item", let item = currentItem else { return }
        defer { currentItem = nil }

        // Google News wraps a redirect URL — decode the real article URL
        let articleLink = decodeGoogleNewsLink(item.link)

        // Image: prefer media:content, fall back to <img> inside description HTML
        let imageURL = item.imageURL.isEmpty
            ? extractFirstImage(from: item.description)
            : item.imageURL

        items.append(NewsItemDTO(
            title:       cleanTitle(item.title),
            source:      item.sourceName.isEmpty ? "Google News" : item.sourceName,
            pubDate:     formatDate(item.pubDate),
            link:        articleLink,
            description: stripHTML(item.description),
        ))
    }

    // MARK: - Private helpers

    /// Google News titles look like: "Article headline - Publisher Name"
    /// Strip the trailing " - Publisher" suffix.
    private func cleanTitle(_ title: String) -> String {
        guard let range = title.range(of: " - ", options: .backwards) else {
            return title
        }
        return String(title[..<range.lowerBound])
    }

    /// Google News <link> is a google.com redirect.
    /// The real URL is sometimes available directly; keep as-is since
    /// opening in SFSafariViewController will follow the redirect fine.
    /// If you need the canonical URL, you'd need a HEAD request.
    private func decodeGoogleNewsLink(_ link: String) -> String {
        // Strip tracking params if present
        if let url = URLComponents(string: link),
           let articleURL = url.queryItems?.first(where: { $0.name == "url" })?.value {
            return articleURL
        }
        return link
    }

    /// Pull the first <img src="..."> from Google News description HTML.
    /// The description looks like:
    /// <ol><li>...<img src="https://lh3.google..."/><a href="...">Title</a>...</li></ol>
    private func extractFirstImage(from html: String) -> String {
        // Fast scan: find `src="` after `<img`
        var searchRange = html.startIndex..<html.endIndex

        while let imgRange = html.range(of: "<img", range: searchRange) {
            let afterImg = imgRange.upperBound..<html.endIndex
            if let srcRange = html.range(of: "src=\"", range: afterImg) {
                let valueStart = srcRange.upperBound
                if let closeQuote = html.range(of: "\"", range: valueStart..<html.endIndex) {
                    return String(html[valueStart..<closeQuote.lowerBound])
                }
            }
            // Advance past this <img tag
            searchRange = imgRange.upperBound..<html.endIndex
        }
        return ""
    }

    /// Fast tag-stripping without WebKit/NSAttributedString overhead.
    private func stripHTML(_ html: String) -> String {
        guard html.contains("<") else { return html }

        var result = ""
        result.reserveCapacity(html.count)
        var inTag = false

        for scalar in html.unicodeScalars {
            switch scalar {
            case "<": inTag = true
            case ">": inTag = false
            default:  if !inTag { result.unicodeScalars.append(scalar) }
            }
        }

        return result
            .replacingOccurrences(of: "&amp;",  with: "&")
            .replacingOccurrences(of: "&lt;",   with: "<")
            .replacingOccurrences(of: "&gt;",   with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#39;",  with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formatDate(_ raw: String) -> String {
        guard let date = Self.dateFormatter.date(from: raw) else { return raw }
        return Self.relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Internal parsed state (class avoids copy on every foundCharacters call)

private final class ParsedItem {
    var title       = ""
    var link        = ""
    var pubDate     = ""
    var description = ""
    var sourceName  = ""
    var sourceURL   = ""
    var imageURL    = ""
}
