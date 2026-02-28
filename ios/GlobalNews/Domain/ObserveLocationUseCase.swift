
import Combine

protocol ObserveLocationUseCase {
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> { get }
}

final class ObserveLocationUseCaseImpl: ObserveLocationUseCase {
    
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> {
        locationRepository.locationUpdatePublisher
    }

    private let locationRepository: LocationRepository

    init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
        
        Task {
            try? await locationRepository.getLocation()
        }
    }
}
