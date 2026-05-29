import Foundation

protocol RSSParser {
    func parse(data: Data) -> [NewsItemDTO]
}

final class GoogleNewsRSSParser: NSObject, RSSParser, XMLParserDelegate {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return f
    }()

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

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName

        switch elementName {
        case "image" where currentItem == nil:
            isInChannelImage = true

        case "item":
            isInChannelImage = false
            currentItem = ParsedItem()

        case "source":
            currentItem?.sourceURL = attributeDict["url"] ?? ""

        case "content" where qName?.hasPrefix("media:") == true:
            if let url = attributeDict["url"], !url.isEmpty {
                currentItem?.imageURL = url
            }

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
        case "guid":        item.guid        += trimmed
        default: break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        defer { currentElement = "" }

        if elementName == "image" && currentItem == nil {
            isInChannelImage = false
            return
        }

        guard elementName == "item", let item = currentItem else { return }
        defer { currentItem = nil }

        let articleLink = decodeGoogleNewsLink(item.link)

        items.append(
            NewsItemDTO(
                guid: item.guid.isEmpty ? articleLink : item.guid,
                title: cleanTitle(item.title),
                source: item.sourceName.isEmpty ? "Google News" : item.sourceName,
                pubDate: item.pubDate,
                link: articleLink,
                description: stripHTML(item.description)
            )
        )
    }

    private func cleanTitle(_ title: String) -> String {
        guard let range = title.range(of: " - ", options: .backwards) else {
            return title
        }
        return String(title[..<range.lowerBound])
    }

    private func decodeGoogleNewsLink(_ link: String) -> String {
        if let url = URLComponents(string: link),
           let articleURL = url.queryItems?.first(where: { $0.name == "url" })?.value {
            return articleURL
        }
        return link
    }

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
}

private final class ParsedItem {
    var guid = ""
    var title = ""
    var link = ""
    var pubDate = ""
    var description = ""
    var sourceName = ""
    var sourceURL = ""
    var imageURL = ""
}
