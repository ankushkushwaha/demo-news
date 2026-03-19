
final class AppServices {
    /// Shared services
    let locationService: LocationService
    let newsService: NewsService

    init(
        locationService: LocationService = LocationServiceImpl(),
        newsService: NewsService = NewsServiceImpl()
    ) {
        self.locationService = locationService
        self.newsService = newsService
    }
}
