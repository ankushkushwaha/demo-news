
import SwiftUI

struct BookmarksView: View {
    @StateObject var viewModel: BookMarkViewModel
    
    var body: some View {
        VStack {
            Text("Bookmarks: \(viewModel.bookmarks.count)")
            
            listView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        List(viewModel.bookmarksList) { item in
            NewsItemView(
                item: item,
                isBookmarked: viewModel.isBookmarked(item),
                onBookmarkTap: { viewModel.toggleBookmark(item) }
            )
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.3), value: viewModel.bookmarks)  // animates on bookmark change
    }
}
