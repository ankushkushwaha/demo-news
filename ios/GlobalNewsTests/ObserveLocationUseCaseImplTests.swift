
import Testing
import Combine
import Foundation
@testable import News

@Suite("ObserveLocationUseCaseImpl")
struct ObserveLocationUseCaseImplTests {

    let repository: MockLocationRepository
    let sut: ObserveLocationUseCaseImpl

    init() {
        repository = MockLocationRepository()
        sut = ObserveLocationUseCaseImpl(locationRepository: repository)
    }


    @Test("locationUpdatePublisher forwards success result from repository")
    func publisher_forwardsSuccess() async {
        let location = UserLocation.stub()
        var received: Result<UserLocation, LocationRepositoryError>?

        let cancellable = await sut.locationUpdatePublisher.sink { received = $0 }

        repository.subject.send(.success(location))

        guard case .success(let value) = received else {
            #expect(Bool(false), "Expected .success, got \(String(describing: received))")
            return
        }
        #expect(value.city == location.city)
    }

    @Test("locationUpdatePublisher forwards failure result from repository")
    func publisher_forwardsFailure() async {
        var received: Result<UserLocation, LocationRepositoryError>?

        let cancellable = sut.locationUpdatePublisher.sink { received = $0 }

        repository.subject.send(.failure(.permissionDenied))

        guard case .failure(let error) = received else {
            #expect(Bool(false), "Expected .failure, got \(String(describing: received))")
            return
        }
        #expect(error == .permissionDenied)
    }

    @Test("locationUpdatePublisher does not emit before repository emits")
    func publisher_doesNotEmitPrematurely() async {
        var received: [Result<UserLocation, LocationRepositoryError>] = []

        let cancellable = await sut.locationUpdatePublisher.sink { received.append($0) }

        #expect(received.isEmpty)
    }

    // MARK: - attemptToGetLocation

    @Test("attemptToGetLocation calls repository getLocation")
    func attemptToGetLocation_callsRepository() async {
        await sut.attemptToGetLocation()

        #expect(repository.getLocationCallCount == 1)
    }

    @Test("attemptToGetLocation can be called multiple times")
    func attemptToGetLocation_multipleCallsForwardedToRepository() async {
        await sut.attemptToGetLocation()
        await sut.attemptToGetLocation()
        await sut.attemptToGetLocation()

        #expect(repository.getLocationCallCount == 3)
    }

    @Test("attemptToGetLocation silently ignores repository errors")
    func attemptToGetLocation_silentlyIgnoresErrors() async {
        repository.getLocationError = LocationRepositoryError.permissionDenied

        // Should not throw — errors are swallowed with try?
        await sut.attemptToGetLocation()

        #expect(repository.getLocationCallCount == 1)
    }
}

// MARK: - Mock

final class MockLocationRepository: LocationRepository {
    let subject = PassthroughSubject<Result<UserLocation, LocationRepositoryError>, Never>()

    var locationUpdatePublisher: AnyPublisher<Result<UserLocation, LocationRepositoryError>, Never> {
        subject.eraseToAnyPublisher()
    }

    var getLocationCallCount = 0
    var getLocationError: LocationRepositoryError?

    func getLocation() async throws -> UserLocation {
        getLocationCallCount += 1
        if let error = getLocationError { throw error }
        return .stub()
    }
}

extension UserLocation {
    static func stub(
        countryCode: String = "DE",
        countryName: String =  "Germany",
        city: String =  "Berlin",
        languageCode: String =  "de"
    ) -> UserLocation {
        UserLocation(countryCode: countryCode, countryName: countryName, city: city, languageCode: languageCode)
    }
}

