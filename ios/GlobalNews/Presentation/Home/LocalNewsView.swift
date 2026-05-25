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
                
                if let lastUpdatedDate = viewModel.lastUpdatedDate {
                    TimelineView(.periodic(from: .now, by: 60)) { _ in
                        Text("Updated: \(lastUpdatedDate.relativeDisplayString)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
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
        .presentAlert(viewModel: viewModel)
    }
    
    private func newsListView() -> some View {
        NewsItemListView(
            items: viewModel.items,
            isBookmarked: { item in
                viewModel.isBookmarked(item)
            },
            toggleBookmarkAction: { item in
                viewModel.toggleBookmark(item)
            }, refreshAction: {
                await viewModel.refresh()
            }
        )
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
