import Foundation
import Combine

protocol LocationRepository {
    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> { get }
  func getLocation() async throws -> UserLocation
}

struct LocationRepositoryImpl: LocationRepository {

    var locationUpdatePublisher: AnyPublisher<UserLocation, LocationRepositoryError> {
        service.locationUpdatePublisher
            .map { $0.toLocation() }
            .mapError { mapToRepositoryError($0) }
            .eraseToAnyPublisher()
    }

    private let service: LocationService

    init(service: LocationService = LocationServiceImpl()) {
        self.service = service
    }

    func getLocation() async throws -> UserLocation {
        do {
            let dto = try await service.fetchLocation()
            return dto.toLocation()
        } catch let error as LocationServiceError {
#if DEBUG
            print(error)
#endif
            throw mapToRepositoryError(error)
        } catch {
            throw LocationRepositoryError.unknown(error)
        }
    }

    private func mapToRepositoryError(_ error: LocationServiceError) -> LocationRepositoryError {
        switch error {
        case .permissionDenied:
                .permissionDenied
        case .locationUnavailable:
                .unavailable
        case .geocodingFailed:
                .unavailable
        }
    }
}

enum LocationRepositoryError: Error, LocalizedError {
    case permissionDenied
    case unavailable
    case unknown(Error)

    var message: String? {
        switch self {
        case .permissionDenied:
            "Location access denied. Please enable in Settings."
        case .unavailable:
            "Could not determine your location."
        case .unknown(let error):
            error.localizedDescription
        }
    }
}
