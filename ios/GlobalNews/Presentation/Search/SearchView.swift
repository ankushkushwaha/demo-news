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
        .presentAlert(viewModel: viewModel)
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search news...", text: $viewModel.searchQuery)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("search_text_field")
                .accessibilityLabel("Enter text to")

            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("search_clear_button")
                .accessibilityLabel("Clear text")
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
        NewsItemListView(
            items: viewModel.items,
            isBookmarked: { item in
                viewModel.isBookmarked(item)
            },
            toggleBookmarkAction: { item in
                viewModel.toggleBookmark(item)
            })
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
