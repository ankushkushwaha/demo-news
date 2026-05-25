
import SwiftUI

struct WorldwideNewsView: View {
    @ObservedObject var viewModel: WorldwideNewsViewModel
    
    init(viewModel: WorldwideNewsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .idle:
                
                if let lastUpdatedDate = viewModel.lastUpdatedDate {
                    TimelineView(.periodic(from: .now, by: 60)) { _ in
                        Text("Updated: \(lastUpdatedDate.relativeDisplayString)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                NewsItemListView(
                    items: viewModel.items,
                    isBookmarked: { item in
                        viewModel.isBookmarked(item)
                    }, toggleBookmarkAction: { item in
                        viewModel.toggleBookmark(item)
                    }, refreshAction: {
                        viewModel.refresh()
                    }
                )

            case .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message, retry: {
                    viewModel.fetchData()
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground)
            .ignoresSafeArea())
        .presentAlert(viewModel: viewModel)
    }
}
