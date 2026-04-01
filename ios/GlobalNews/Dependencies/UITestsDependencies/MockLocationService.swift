
import Combine

final class MockLocationService: LocationService {

    private let subject = PassthroughSubject<Result<LocationDTO, LocationServiceError>, Never>()

    var locationUpdatePublisher: AnyPublisher<Result<LocationDTO, LocationServiceError>, Never> {
        subject.eraseToAnyPublisher()
    }

    static let stubbedLocation = LocationDTO(
        latitude: 60.1699,
        longitude: 24.9384,
        countryCode: "FI",
        countryName: "Finland",
        languageCode: "fi",
        city: "Helsinki"
    )

    func fetchLocation() async throws -> LocationDTO {
        let dto = MockLocationService.stubbedLocation
        subject.send(.success(dto))
        return dto
    }

    func startMonitoring() {
        subject.send(.success(MockLocationService.stubbedLocation))
    }

    func stopMonitoring() { }
}
