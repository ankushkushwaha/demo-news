import Foundation

#if DEBUG
enum AppContainerFactory {
    
    static func makeContainer() -> AppContainer {
        let mode = AppRunningMode.current(from: ProcessInfo.processInfo.arguments)
        
        switch mode {
        case .normal:
            return AppContainer()
            
        case .uiTestSuccess:
            return AppContainer(
                states: .makeForUITests(),
                services: AppServices(
                    locationService: MockLocationService(),
                    newsService: MockNewsService()
                )
            )
            
        case .uiTestError:
            return AppContainer(
                states: .makeForUITests(),
                services: AppServices(
                    locationService: MockLocationService(),
                    newsService: MockFailingNewsService()
                )
            )
            
        case .uiTestEmpty:
            return AppContainer(
                states: .makeForUITests(),
                services: AppServices(
                    locationService: MockLocationService(),
                    newsService: MockEmptyNewsService()
                )
            )
        }
    }
}

#else
// For RELEASE / PROD
enum AppContainerFactory {
    
    static func makeContainer() -> AppContainer {
        AppContainer()
    }
}

#endif
