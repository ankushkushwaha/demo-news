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
                    newsService: NewsServiceImpl(
                        networkSession: MockNetworkSession.success()
                    )
                )
            )
            
        case .uiTestError:
            return AppContainer(
                states: .makeForUITests(),
                services: AppServices(
                    locationService: MockLocationService(),
                    newsService: NewsServiceImpl(
                        networkSession: MockNetworkSession.error()
                    )
                )
            )
            
        case .uiTestEmpty:
            return AppContainer(
                states: .makeForUITests(),
                services: AppServices(
                    locationService: MockLocationService(),
                    newsService: NewsServiceImpl(
                        networkSession: MockNetworkSession.empty()
                    )
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
