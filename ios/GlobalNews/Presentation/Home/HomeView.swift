import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var localViewModel: LocalNewsViewModel
    @StateObject private var worldwideViewModel: WorldwideNewsViewModel

    init(
        viewModel: HomeViewModel,
        localViewModel: LocalNewsViewModel,
        worldwideViewModel: WorldwideNewsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _localViewModel = StateObject(wrappedValue: localViewModel)
        _worldwideViewModel = StateObject(wrappedValue: worldwideViewModel)
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
            .padding(.horizontal)
            .padding(.vertical, 8)

            switch viewModel.selectedSegment {
            case .localNews:
                LocalNewsView(viewModel: localViewModel)
            case .worldwide:
                WorldwideNewsView(viewModel: worldwideViewModel)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
