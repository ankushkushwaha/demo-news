import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var container: AppContainer
    init(
        viewModel: HomeViewModel,
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
     }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Segment", selection: Binding(
                get: { viewModel.selectedSegment },
                set: { viewModel.selectSegment($0) }
            )) {
                ForEach(HomeViewModel.Segment.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            switch viewModel.selectedSegment {
            case .localNews:
                LocalNewsView(viewModel: container.makeLocalNewsViewModel())
            case .worldwide:

                WorldwideNewsView(viewModel: container.makeWorldwideNewsViewModel())
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
