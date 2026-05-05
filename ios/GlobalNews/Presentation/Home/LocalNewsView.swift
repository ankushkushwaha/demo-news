//
//  HomeView.swift
//  GlobalNews
//
//  Created by Ankush on 13.3.2026.
//
import SwiftUI

struct SettingView: View {
    var body: some View {
        Text("Setting Screen")
    }
}

struct LocalNewsView: View {
    
    @ObservedObject var viewModel: LocalNewsViewModel
    @State var openSafari = false
    
    init(viewModel: LocalNewsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            switch viewModel.currentState {
                
            case .idle(let location):
                if let location {
                    locationTextView(location)
                }
                
                newsListView()
                
            case .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message, retry: {
                    viewModel.attemptToGetLocation()
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground)
            .ignoresSafeArea())
    }
    
    private func newsListView() -> some View {
        NewsItemListView(
            items: viewModel.items,
            isBookmarked: { item in
                viewModel.isBookmarked(item)
            },
            toggleBookmarkAction: { item in
                viewModel.toggleBookmark(item)
            },
            bookmarkErrorMessage: viewModel.bookmarkError)
    }
    
    private func locationTextView(_ location: String) -> some View {
        HStack {
            Spacer()
            Image(systemName: "location")
                .font(.footnote)
            Text(location)
                .font(.footnote)
        }
        .padding(.horizontal)
    }
}

struct NewsItemListView: View {
    let items: [NewsItem]
    let isBookmarked: (NewsItem) -> Bool
    let toggleBookmarkAction: (NewsItem) -> Void
    let bookmarkErrorMessage: String?
    
    @State private var showBookmarkError = false

    @State private var selectedURL: String?
    var body: some View {
        List(items, id: \.id) { item in
            
            NewsItemView(
                item: item,
                isBookmarked: isBookmarked(item),
                onBookmarkTap: {
                toggleBookmarkAction(item)
            })
            
            .listRowInsets(
                EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .onTapGesture {
                selectedURL = item.link
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.3), value: items)
        .sheet(item: $selectedURL) { urlString in
            if let url = URL(string: urlString) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: bookmarkErrorMessage) { _, newValue in
            showBookmarkError = newValue != nil
        }
        .alert("Bookmark Failed", isPresented: $showBookmarkError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(bookmarkErrorMessage ?? "")
        })
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
