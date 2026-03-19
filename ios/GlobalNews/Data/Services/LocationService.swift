import CoreLocation
import MapKit
import Combine

protocol LocationService {
    var locationUpdatePublisher: AnyPublisher<LocationDTO, LocationServiceError> { get }
    func fetchLocation() async throws -> LocationDTO
    func startMonitoring()
    func stopMonitoring()
}

final class LocationServiceImpl: NSObject, LocationService, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private let subject = PassthroughSubject<LocationDTO, LocationServiceError>()
    
    var locationUpdatePublisher: AnyPublisher<LocationDTO, LocationServiceError> {
        subject.eraseToAnyPublisher()
    }
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
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
    
    func fetchLocation() async throws -> LocationDTO {
        let location = try await requestLocation()
        return try await reverseGeocode(location)
    }
    
    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        continuation?.resume(returning: location)
        continuation = nil
        
            Task {
                do {
                    let dto = try await reverseGeocode(location)
                    subject.send(dto)
                } catch {
                    subject.send(completion: .failure(.geocodingFailed))
                }
            }
    }
    private func requestLocation() async throws -> CLLocation {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            guard locationManager.authorizationStatus != .denied,
                  locationManager.authorizationStatus != .restricted else {
                throw LocationServiceError.permissionDenied
            }
        case .denied, .restricted:
            throw LocationServiceError.permissionDenied
        default:
            break
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    private func reverseGeocode(_ location: CLLocation) async throws -> LocationDTO {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw LocationServiceError.geocodingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            request.getMapItems {
                items,
                error in
                if error != nil {
                    continuation.resume(throwing: LocationServiceError.geocodingFailed)
                    return
                }
                
                guard let item = items?.first else {
                    continuation.resume(throwing: LocationServiceError.geocodingFailed)
                    return
                }
                
                let countryCode  = item.placemark.countryCode
                ?? Locale.current.region?.identifier
                
                let languageCode = Locale.current.language.languageCode?.identifier
                
                let countryName = item.addressRepresentations?.regionName
                
                let city = item.addressRepresentations?.cityWithContext
                continuation.resume(
                    returning: LocationDTO(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        countryCode: countryCode,
                        countryName: countryName,
                        languageCode: languageCode,
                        city: city
                    )
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: LocationServiceError.locationUnavailable)
        continuation = nil
    }
}

enum LocationServiceError: Error {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
}
