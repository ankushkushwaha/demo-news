import SwiftUI
import Combine

struct BookmarksView: View {
    @StateObject var viewModel: BookMarkViewModel
    @State private var showBookmarkError = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Bookmarks: \(viewModel.bookmarks.count)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.footnote)
            }
            .padding(.horizontal)

            if viewModel.bookmarks.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onReceive(viewModel.$bookmarkError.compactMap { $0 }) { _ in
            showBookmarkError = true
        }
        .alert("Bookmark Failed", isPresented: $showBookmarkError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.bookmarkError ?? "")
        })
    }

    private var listView: some View {
        NewsItemListView(
            items: viewModel.bookmarks,
            isBookmarked: { item in
                viewModel.isBookmarked(item)
            },
            toggleBookmarkAction: { item in
                viewModel.toggleBookmark(item)
            },
            bookmarkErrorMessage: viewModel.bookmarkError)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Bookmarks",
            systemImage: "bookmark",
            description: Text("Articles you bookmark will appear here.")
        )
    }
}
