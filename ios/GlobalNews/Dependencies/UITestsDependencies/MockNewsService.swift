
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

// MARK: - Stubbed Data

extension NewsItemDTO {
    static var stubbedXMLData: Data {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>Swift 6 Concurrency Deep Dive</title>
                    <source>Swift Weekly</source>
                    <pubDate>20 Mar 2026</pubDate>
                    <link>https://example.com/1</link>
                    <description>Everything you need to know about Swift 6.</description>
                </item>
                <item>
                    <title>Apple Vision Pro 2 Announced</title>
                    <source>Tech Crunch</source>
                    <pubDate>19 Mar 2026</pubDate>
                    <link>https://example.com/2</link>
                    <description>Apple unveils the next generation of spatial computing.</description>
                </item>
                <item>
                    <title>SwiftUI Performance Tips</title>
                    <source>Hacking with Swift</source>
                    <pubDate>18 Mar 2026</pubDate>
                    <link>https://example.com/3</link>
                    <description>Practical techniques to speed up your SwiftUI apps.</description>
                </item>
            </channel>
        </rss>
        """.data(using: .utf8)!
    }
}
#endif
