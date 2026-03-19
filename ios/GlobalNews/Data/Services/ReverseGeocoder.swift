import CoreLocation
import MapKit

protocol ReverseGeocoder {
    func geocode(_ location: CLLocation) async throws -> LocationDTO
}

final class MKReverseGeocoder: ReverseGeocoder {

    func geocode(_ location: CLLocation) async throws -> LocationDTO {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw LocationServiceError.geocodingFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            request.getMapItems { items, error in
                if error != nil {
                    continuation.resume(throwing: LocationServiceError.geocodingFailed)
                    return
                }

                guard let item = items?.first else {
                    continuation.resume(throwing: LocationServiceError.geocodingFailed)
                    return
                }

                let countryCode = item.placemark.countryCode
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
}
