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

struct NewsView: View {
    
    @StateObject var viewModel: NewsViewModel
    @State var openSafari = false
    init(viewModel: NewsViewModel) {
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
                
                NewsItemListView(viewModel: viewModel)
                
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
    @ObservedObject var viewModel: NewsViewModel

    @State private var selectedURL: String?
    var body: some View {
        List(viewModel.items, id: \.id) { item in
            
            NewsItemView(
                item: item,
                isBookmarked: viewModel.isBookmarked(item),
                onBookmarkTap: {
                    viewModel.toggleBookmark(item)
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
