import SwiftUI
import Combine

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @State var showBookmarkError: Bool = false
    
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            content
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.$bookmarkError.compactMap { $0 }) { _ in
            showBookmarkError = true
        }
        .alert("Bookmark Failed", isPresented: $showBookmarkError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.bookmarkError ?? "")
        })

    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search news...", text: $viewModel.searchQuery)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("search_text_field")
            
            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("search_clear_button")
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.currentState {
        case .idle:
            resultsList
        case .loading:
            LoadingView()
        case .empty:
            emptyPrompt(message: "No result found")
        case .error(let message):
            emptyPrompt(message: "Error\n\(message)")
        }
    }
    
    private var resultsList: some View {
        List(viewModel.items) { item in
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
    }
    
    private func emptyPrompt(message: String) -> some View {
        ContentUnavailableView(
            "",
            systemImage: "magnifyingglass",
            description: Text(message)
        )
        .accessibilityIdentifier("search_empty_prompt")
    }
}
