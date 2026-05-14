import Foundation

extension Date {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    var relativeDisplayString: String {
        guard self != .distantPast else { return "" }
        return Self.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }
}
