
#if DEBUG
import Foundation

final class MockNetworkSession: NetworkSession {
    var result: Result<(Data, URLResponse), Error>

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

extension MockNetworkSession {
    static func success() -> MockNetworkSession {
        MockNetworkSession(result: .success((
            NewsItemDTO.stubbedXMLData,
            makeResponse(statusCode: 200)
        )))
    }

    static func error() -> MockNetworkSession {
        MockNetworkSession(result: .failure(URLError(.notConnectedToInternet)))
    }

    static func empty() -> MockNetworkSession {
        MockNetworkSession(result: .success((
            Data(),
            makeResponse(statusCode: 200)
        )))
    }

    private static func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

extension NewsItemDTO {
    static var stubbedXMLData: Data {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <guid isPermaLink="false">https://example.com/1</guid>
                    <title>Swift 6 Concurrency Deep Dive - Swift Weekly</title>
                    <source url="https://swiftweekly.com">Swift Weekly</source>
                    <pubDate>Thu, 20 Mar 2026 10:00:00 GMT</pubDate>
                    <link>https://example.com/1</link>
                    <description>Everything you need to know about Swift 6.</description>
                </item>
                <item>
                    <guid isPermaLink="false">https://example.com/2</guid>
                    <title>Apple Vision Pro 2 Announced - Tech Crunch</title>
                    <source url="https://techcrunch.com">Tech Crunch</source>
                    <pubDate>Wed, 19 Mar 2026 08:30:00 GMT</pubDate>
                    <link>https://example.com/2</link>
                    <description>Apple unveils the next generation of spatial computing.</description>
                </item>
                <item>
                    <guid isPermaLink="false">https://example.com/3</guid>
                    <title>SwiftUI Performance Tips - Hacking with Swift</title>
                    <source url="https://hackingwithswift.com">Hacking with Swift</source>
                    <pubDate>Tue, 18 Mar 2026 06:00:00 GMT</pubDate>
                    <link>https://example.com/3</link>
                    <description>Practical techniques to speed up your SwiftUI apps.</description>
                </item>
            </channel>
        </rss>
        """.data(using: .utf8)!
    }
}
#endif
