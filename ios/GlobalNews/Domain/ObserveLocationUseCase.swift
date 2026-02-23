
import Combine

protocol ObserveLocationUseCase {
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> { get }
}

class ObserveLocationUseCaseImpl: ObserveLocationUseCase {
    
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> {
        locationRepository.locationUpdatePublisher
    }

    private let locationRepository: LocationRepository

    init(locationRepository: LocationRepository = LocationRepositoryImpl()) {
        self.locationRepository = locationRepository
        
        Task {
            try? await locationRepository.getLocation()
        }
    }
    
}
