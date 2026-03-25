
import SwiftUI

struct WorldwideNewsView: View {
    @ObservedObject var viewModel: WorldwideNewsViewModel

    @State var openSafari = false
    
    init(viewModel: WorldwideNewsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .idle:
                NewsItemListView(
                    items: viewModel.items,
                    isBookmarked: { item in
                        viewModel.isBookmarked(item)
                    }, toggleBookmarkAction: { item in
                        viewModel.toggleBookmark(item)
                    })

            case .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message, retry: nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground)
            .ignoresSafeArea())
    }
}
