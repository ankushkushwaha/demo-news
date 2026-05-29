
final class AppServices {
    /// Shared services
    let locationService: LocationService
    let newsService: NewsService
    let analyticsService: AnalyticsService

    init(
        locationService: LocationService = LocationServiceImpl(),
        newsService: NewsService = NewsServiceImpl(),
        analyticsService: AnalyticsService = AppServices.makeAnalyticsService()
    ) {
        self.locationService = locationService
        self.newsService = newsService
        self.analyticsService = analyticsService
    }
    
    private static func makeAnalyticsService() -> AnalyticsService {
        CompositeAnalyticsService(
            services: [
                FirebaseAnalyticsServiceImpl(),
                DatadogAnalyticsServiceImpl()
            ]
        )
    }
}
