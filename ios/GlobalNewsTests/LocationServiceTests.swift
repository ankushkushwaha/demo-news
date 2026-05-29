import Testing
import CoreLocation
import Combine
@testable import News

@Suite("LocationService")
struct LocationServiceTests {

    let locationManager: MockLocationManager
    let geocoder: MockGeocoder
    let sut: LocationServiceImpl

    init() {
        locationManager = MockLocationManager()
        geocoder = MockGeocoder()
        sut = LocationServiceImpl(locationManager: locationManager, geocoder: geocoder)
    }

    @MainActor // To remove warnings
    @Test("Throws permissionDenied when authorization is denied")
    func fetchLocation_permissionDenied() async {
        locationManager.authorizationStatus = .denied

        await #expect(throws: LocationServiceError.permissionDenied) {
            try await sut.fetchLocation()
        }
    }

    @MainActor // To remove warnings
    @Test("Returns DTO when authorized and location succeeds")
    func fetchLocation_success() async throws {
        locationManager.authorizationStatus = .authorizedWhenInUse
        geocoder.result = .success(.stub)

        locationManager.onNextLocationRequest { [self] in
            sut.locationManager(
                CLLocationManager(),
                didUpdateLocations: [CLLocation(latitude: 60.1699, longitude: 24.9384)]
            )
        }

        let dto = try await sut.fetchLocation()
        #expect(dto.countryCode == LocationDTO.stub.countryCode)
        #expect(dto.city == LocationDTO.stub.city)
    }

    @MainActor // To remove warnings
    @Test("Throws locationUnavailable when hardware fails")
    func fetchLocation_hardwareFailure() async {
        locationManager.authorizationStatus = .authorizedWhenInUse

        locationManager.onNextLocationRequest { [self] in
            sut.locationManager(
                CLLocationManager(),
                didFailWithError: LocationServiceError.locationUnavailable
            )
        }

        await #expect(throws: LocationServiceError.locationUnavailable) {
            try await sut.fetchLocation()
        }
    }

    @MainActor // To remove warnings
    @Test("Publisher emits success when location updates")
    func publisher_emitsSuccess() async throws {
        geocoder.result = .success(.stub)

        var cancellables = Set<AnyCancellable>()
        let result = try await withCheckedThrowingContinuation { continuation in
            sut.locationUpdatePublisher
                .first() // Prevents crash -> continuation.resume twice
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)

            sut.locationManager(
                CLLocationManager(),
                didUpdateLocations: [CLLocation(latitude: 60.1699, longitude: 24.9384)]
            )
        }

        guard case .success(let dto) = result else {
            Issue.record("Expected success, got failure")
            return
        }
        #expect(dto.countryCode == LocationDTO.stub.countryCode)
    }

    @MainActor // To remove warnings
    @Test("Publisher emits geocodingFailed when geocoder throws")
    func publisher_emitsGeocodingFailure() async throws {
        geocoder.result = .failure(LocationServiceError.geocodingFailed)

        var cancellables = Set<AnyCancellable>()
        let result = try await withCheckedThrowingContinuation { continuation in
            sut.locationUpdatePublisher
                .first() // To prevent calling continuation.resume twice, which will result crash
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)

            sut.locationManager(
                CLLocationManager(),
                didUpdateLocations: [CLLocation(latitude: 60.1699, longitude: 24.9384)]
            )
        }

        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got success")
            return
        }
        #expect(error == .geocodingFailed)
    }

    @Test("startMonitoring delegates to location manager")
    func startMonitoring() {
        sut.startMonitoring()
        #expect(locationManager.startUpdatingLocationCalled)
    }

    @Test("stopMonitoring delegates to location manager")
    func stopMonitoring() {
        sut.stopMonitoring()
        #expect(locationManager.stopUpdatingLocationCalled)
    }
}

// MARK: - Mocks

final class MockLocationManager: LocationManager {
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = 0
    var startUpdatingLocationCalled = false
    var stopUpdatingLocationCalled = false
    var requestLocationCalled = false

    private var onRequestLocation: (() -> Void)?

    func onNextLocationRequest(_ action: @escaping () -> Void) {
        onRequestLocation = action
    }

    func requestWhenInUseAuthorization() {}
    func startUpdatingLocation() { startUpdatingLocationCalled = true }
    func stopUpdatingLocation() { stopUpdatingLocationCalled = true }

    func requestLocation() {
        requestLocationCalled = true
        onRequestLocation?()
        onRequestLocation = nil
    }
}

final class MockGeocoder: ReverseGeocoder {
    var result: Result<LocationDTO, Error> = .success(.stub)

    func geocode(_ location: CLLocation) async throws -> LocationDTO {
        try result.get()
    }
}

extension LocationDTO {
    static let stub = LocationDTO(
        latitude: 60.1699,
        longitude: 24.9384,
        countryCode: "US",
        countryName: "United States",
        languageCode: "en",
        city: "Los Angeles"
    )
}
