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
        .onReceive(viewModel.$errorMessage.compactMap { $0 }) { _ in
            showBookmarkError = true
        }
        .alert("Bookmark Failed", isPresented: $showBookmarkError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var listView: some View {
        List(viewModel.bookmarks) { item in
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.bookmarks)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Bookmarks",
            systemImage: "bookmark",
            description: Text("Articles you bookmark will appear here.")
        )
    }
}
