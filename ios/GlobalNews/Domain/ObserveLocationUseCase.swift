
import Combine

protocol ObserveLocationUseCase {
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> { get }
    func attemptToGetLocation() async
}

final class ObserveLocationUseCaseImpl: ObserveLocationUseCase {

    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> {
        locationRepository.locationUpdatePublisher
    }

    private let locationRepository: LocationRepository

    init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }

    func attemptToGetLocation() async {
        _ = try? await locationRepository.getLocation()
    }
}
