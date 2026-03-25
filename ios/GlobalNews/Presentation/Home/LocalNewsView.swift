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

struct DetailView: View {
    let urlString: String
    
    var body: some View {
        if let url = URL(string: urlString) {
            SafariView(url: url)
                .ignoresSafeArea()
        } else {
            ContentUnavailableView(
                "Invalid URL",
                systemImage: "link.badge.xmark"
            )
        }
    }
}

struct LocalNewsView: View {
    
    @StateObject var viewModel: LocalNewsViewModel
    @State var openSafari = false
    
    init(viewModel: LocalNewsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .idle(let location):
                if let location {
                    HStack {
                        Spacer()
                        Image(systemName: "location")
                            .font(.footnote)
                        Text(location)
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                } else {
                    EmptyView()
                }
                
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
                ErrorView(message: message, retry: {
                    viewModel.attemptToGetLocation()
                })
            }
        }
        .background(Color(.systemGroupedBackground)
            .ignoresSafeArea())
    }
}

struct NewsItemListView: View {
    let items: [NewsItem]
    let isBookmarked: (NewsItem) -> Bool
    let toggleBookmarkAction: (NewsItem) -> Void
    
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
        .sheet(item: $selectedURL) { urlString in
            if let url = URL(string: urlString) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
