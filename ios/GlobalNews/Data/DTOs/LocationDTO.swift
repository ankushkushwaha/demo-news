
struct LocationDTO {
    let latitude: Double
    let longitude: Double
    let countryCode: String?
    let countryName: String?
    let languageCode: String?
    let city: String?
}

extension LocationDTO {
    func toLocation() -> UserLocation {
        UserLocation(
            countryCode: countryCode,
            countryName: countryName,
            city: city,
            languageCode: languageCode
        )
    }
    
}





struct UserLocation {
    let countryCode: String?
    let countryName: String?
    let city: String?
    let languageCode: String?

    var hl: String? {
        guard let languageCode,
              let countryCode else { return nil }
        return "\(languageCode)-\(countryCode)"
    }
    var gl: String? {
        guard let countryCode  else { return nil}
        return countryCode
    }
    
    var locationName: String? {
            let components = [city, countryName].compactMap { $0 }
            guard !components.isEmpty else { return nil }
            return components.joined(separator: ", ")
        }
}
