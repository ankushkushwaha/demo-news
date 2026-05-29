import SwiftUI

struct NewsItemListView: View {
    let items: [NewsItem]
    let isBookmarked: (NewsItem) -> Bool
    let toggleBookmarkAction: (NewsItem) -> Void
    var refreshAction: (() async -> Void)?

    @State private var showBookmarkError = false

    @EnvironmentObject var router: Router
    
    var body: some View {
        List(items, id: \.id) { item in
            
            NewsItemView(
                item: item,
                isBookmarked: isBookmarked(item),
                onBookmarkTap: {
                toggleBookmarkAction(item)
            })
            .listRowInsets(
                EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8)
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .onTapGesture {
                router.push(.detail(item.link))
            }
        }
        .listStyle(.plain)
        .ignoresSafeArea(edges: [.top, .leading, .trailing])
        .animation(.easeInOut(duration: 0.3), value: items)
        .refreshable {
            await refreshAction?()
        }
    }
}
