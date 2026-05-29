import Testing
import Combine
@testable import News

struct LocationRepositoryImplTests {
    
    let service: MockLocationService
    let sut: LocationRepositoryImpl
    
    init() {
        service = MockLocationService()
        sut = LocationRepositoryImpl(service: service)
    }
    
    
    @Test("getLocation returns mapped UserLocation on success")
    func getLocation_success() async throws {
        let dto = LocationDTO.stub()
        service.fetchLocationResult = dto
        
        let result = try await sut.getLocation()
        
        #expect(result.countryCode == dto.countryCode)
        #expect(result.countryName == dto.countryName)
        #expect(result.city == dto.city)
        #expect(result.languageCode == dto.languageCode)
    }
    
    @Test("getLocation maps permissionDenied service error to repository error")
    func getLocation_permissionDenied() async {
        service.error = .permissionDenied
        await #expect(throws: LocationRepositoryError.permissionDenied) {
            try await sut.getLocation()
        }
    }
    
    @Test("getLocation maps locationUnavailable service error to repository error")
    func getLocation_locationUnavailable() async {
        service.error = .locationUnavailable
        await #expect(throws: LocationRepositoryError.unavailable) {
            try await sut.getLocation()
        }
    }
    
    @Test("getLocation maps geocodingFailed service error to repository error")
    func getLocation_geocodingFailed() async {
        
        service.error = .geocodingFailed
        
        await #expect(throws: LocationRepositoryError.unavailable) {
            try await sut.getLocation()
        }
    }
    
    // MARK: locationUpdatePublisher
    
    @Test("locationUpdatePublisher emits mapped UserLocation on service update")
    func publisher_emitsLocation() async throws {
        let dto = LocationDTO.stub()
        var received: [UserLocation] = []
        var cancellables = Set<AnyCancellable>()
        
        await sut.locationUpdatePublisher
            .sink{ result in
                if case .success(let location) = result {
                    received.append(location)
                }
            }
            .store(in: &cancellables)
        
        service.emit(dto)
        
        #expect(received.count == 1)
        #expect(received.first?.countryCode == dto.countryCode)
        #expect(received.first?.city == dto.city)
    }
    
    @Test("locationUpdatePublisher emits multiple updates in order")
    func publisher_emitsMultipleLocations() async throws {
        let berlin = LocationDTO.stub(city: "Berlin")
        let munich = LocationDTO.stub(city: "Munich")
        var received: [UserLocation] = []
        var cancellables = Set<AnyCancellable>()
        
        await sut.locationUpdatePublisher
            .sink{ result in
                if case .success(let location) = result {
                    received.append(location)
                }
            }
            .store(in: &cancellables)
        
        service.emit(berlin)
        service.emit(munich)
        
        #expect(received.count == 2)
        #expect(received[0].city == "Berlin")
        #expect(received[1].city == "Munich")
    }
    
    @Test("locationUpdatePublisher maps locationUnavailable to repository error")
    func publisher_locationUnavailable() async {
        var receivedError: LocationRepositoryError?
        var cancellables = Set<AnyCancellable>()
        
        await sut.locationUpdatePublisher
            .sink { result in
                if case .failure(let error) = result {
                    receivedError = error
                }
            }
            .store(in: &cancellables)

        service.emitFailure(.locationUnavailable)
                
        #expect(receivedError == LocationRepositoryError.unavailable)
    }
    
    @Test("locationUpdatePublisher maps geocodingFailed to repository error")
    func publisher_geocodingFailed() async {
        var receivedError: LocationRepositoryError?
        var cancellables = Set<AnyCancellable>()
        
        await sut.locationUpdatePublisher
            .sink{ result in
                if case .failure(let error) = result {
                    receivedError = error
                }
            }
            .store(in: &cancellables)
        
        service.emitFailure(.geocodingFailed)
        
        #expect(receivedError == LocationRepositoryError.unavailable)
    }
}


// MARK: - Mock

final class MockLocationService: LocationService {

    
    
    private let subject = PassthroughSubject<Result<LocationDTO, LocationServiceError>, Never>()

    var locationUpdatePublisher: AnyPublisher<Result<LocationDTO, LocationServiceError>, Never> {
        subject.eraseToAnyPublisher()
    }
    
    var error: LocationServiceError?
    var fetchLocationResult: LocationDTO?
    var startMonitoringCallCount = 0
    var stopMonitoringCallCount = 0
    
    func fetchLocation() async throws -> LocationDTO {
        if let error {
            throw error
        }
        return fetchLocationResult!
    }
    
    func startMonitoring() {
        startMonitoringCallCount += 1
    }
    
    func stopMonitoring() {
        stopMonitoringCallCount += 1
    }
    
    func emit(_ dto: LocationDTO) {
        subject.send(.success(dto))
    }
    
    func emitFailure(_ error: LocationServiceError) {
        subject.send(.failure(error))
    }
}

extension LocationRepositoryError: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permissionDenied, .permissionDenied), (.unavailable, .unavailable): true
        case (.unknown, .unknown): true
        default: false
        }
    }
}

extension LocationDTO {
    static func stub(
        latitude: Double = 52.5,
        longitude: Double = 13.4,
        countryCode: String? = "DE",
        countryName: String? = "Germany",
        languageCode: String? = "de",
        city: String? = "Berlin"
    ) -> LocationDTO {
        LocationDTO(
            latitude: latitude,
            longitude: longitude,
            countryCode: countryCode,
            countryName: countryName,
            languageCode: languageCode,
            city: city
        )
    }
}
