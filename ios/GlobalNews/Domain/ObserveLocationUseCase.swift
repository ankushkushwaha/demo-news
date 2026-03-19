
import Combine

protocol ObserveLocationUseCase {
    var locationUpdatePublisher: AnyPublisher<Result<UserLocation, LocationRepositoryError>, Never> { get }
    func attemptToGetLocation() async
}

final class ObserveLocationUseCaseImpl: ObserveLocationUseCase {

    var locationUpdatePublisher: AnyPublisher<Result<UserLocation, LocationRepositoryError>, Never> {
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
