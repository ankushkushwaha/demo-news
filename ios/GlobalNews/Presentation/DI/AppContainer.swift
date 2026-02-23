//
//  AppContainer.swift
//  GlobalNews
//
//  Created by Ankush on 23.2.2026.
//

import Foundation
import Combine

class AppStates {
    
}

class AppServices {
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

class AppContainer: ObservableObject {
    let states: AppStates
    let services: AppServices
    
    init(
        states: AppStates = AppStates(),
        services: AppServices = AppServices()
    ) {
        self.states = states
        self.services = services
    }
    
    func makeLocationRepository() -> LocationRepository {
        LocationRepositoryImpl(service: services.locationService)
    }
    
    func makeNewsRepository() -> NewsRepository {
        NewsRepositoryImpl(service: services.newsService)
    }
    
    func makeNewsViewModel() -> NewsViewModel {
        NewsViewModel(
            fetchNewsUseCase: FetchNewsUseCaseImpl(),
            observeLocationUseCase: ObserveLocationUseCaseImpl(
                locationRepository: makeLocationRepository()
            )
        )
    }
}
