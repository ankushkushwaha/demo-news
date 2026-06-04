
import Foundation

protocol AnalyticsService {
    func sendEvent(_ eventName: String, params: [String])
    func log(_ eventName: String, params: [String])
}

extension AnalyticsService {
    func log(_ eventName: String, params: [String]) {
#if DEBUG
        print(
"""
-----------------
ServiceName: \(Self.self)
EventName: \(eventName)
Params: \(params)
--------------
"""
        )
#endif
    }
}

final class FirebaseAnalyticsServiceImpl: AnalyticsService {
    func sendEvent(_ eventName: String, params: [String]) {
        log(eventName, params: params)
    }
}

final class DatadogAnalyticsServiceImpl: AnalyticsService {
    func sendEvent(_ eventName: String, params: [String]) {
        log(eventName, params: params)
    }
}

final class CompositeAnalyticsService: AnalyticsService {
    private let services: [AnalyticsService]

    init(services: [AnalyticsService]) {
        self.services = services
    }

    func sendEvent(_ eventName: String, params: [String]) {
        services.forEach {
            $0.sendEvent(
                eventName,
                params: params
            )
        }
    }
}
