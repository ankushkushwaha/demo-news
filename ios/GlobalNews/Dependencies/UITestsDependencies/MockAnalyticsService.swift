
import Foundation

final class MockAnalyticsService: AnalyticsService {
    func sendEvent(_ eventName: String, params: [String]) { }
}
