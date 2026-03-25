import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    enum Segment: String, CaseIterable {
        case localNews = "Local News"
        case worldwide = "Worldwide"
    }

    @Published private(set) var selectedSegment: Segment = .localNews

    func selectSegment(_ segment: Segment) {
        selectedSegment = segment
    }
}
