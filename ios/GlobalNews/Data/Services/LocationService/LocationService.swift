import CoreLocation
import MapKit
import Combine

protocol LocationService {
    var locationUpdatePublisher: AnyPublisher<Result<LocationDTO, LocationServiceError>, Never> { get }
    func fetchLocation() async throws -> LocationDTO
    func startMonitoring()
    func stopMonitoring()
}

final class LocationServiceImpl: NSObject, LocationService, CLLocationManagerDelegate {

    var locationUpdatePublisher: AnyPublisher<Result<LocationDTO, LocationServiceError>, Never> {
        subject.eraseToAnyPublisher()
    }

    private var locationManager: LocationManager
    private let geocoder: ReverseGeocoder
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private let subject = PassthroughSubject<Result<LocationDTO, LocationServiceError>, Never>()

    init(
        locationManager: LocationManager = CLLocationManager(),
        geocoder: ReverseGeocoder = MKReverseGeocoder()
    ) {
        self.locationManager = locationManager
        self.geocoder = geocoder
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

#if targetEnvironment(simulator)
        startMonitoring()
#endif
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - LocationService

    func fetchLocation() async throws -> LocationDTO {
        let location = try await requestLocation()
        return try await geocoder.geocode(location)
    }

    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        authorizationContinuation?.resume(returning: manager.authorizationStatus)
        authorizationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        continuation?.resume(returning: location)
        continuation = nil

        Task {
            do {
                let dto = try await geocoder.geocode(location)
                subject.send(.success(dto))
            } catch {
                subject.send(.failure(.geocodingFailed))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: LocationServiceError.locationUnavailable)
        continuation = nil
    }

    // MARK: - Private

    private func requestLocation() async throws -> CLLocation {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            let status = await withCheckedContinuation { continuation in
                authorizationContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
            guard status == .authorizedWhenInUse || status == .authorizedAlways else {
                subject.send(.failure(.permissionDenied))
                throw LocationServiceError.permissionDenied
            }
        case .denied, .restricted:
            subject.send(.failure(.permissionDenied))
           throw LocationServiceError.permissionDenied
        default:
            break
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
}

enum LocationServiceError: Error, Equatable {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
}
