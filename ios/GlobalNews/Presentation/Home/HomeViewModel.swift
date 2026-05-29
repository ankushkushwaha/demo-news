import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    enum Segment: String, CaseIterable {
        case worldwide = "Worldwide"
        case localNews = "Local News"
    }

    @Published private(set) var selectedSegment: Segment = .worldwide

    func selectSegment(_ segment: Segment) {
        selectedSegment = segment
    }
}
