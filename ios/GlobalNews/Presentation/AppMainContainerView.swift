
import SwiftUI

struct AppMainContainerView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            AppTabView()
                .navigationDestination(for: Router.Route.self) { route in
                    switch route {
                    case .detail(let url):
                        DetailView(urlString: url)
                    case .setting:
                        SettingView()
                    }
                }
        }
        .withSideMenu()
    }
}

struct AppTabView: View {
    @EnvironmentObject var container: AppContainer
    
    var body: some View {
        VStack {
            TabView {
                HomeView(
                    viewModel: HomeViewModel(),
                    localViewModel: container.makeLocalNewsViewModel(),
                    worldwideViewModel: container.makeWorldwideNewsViewModel()
                )
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                SearchView(
                    viewModel: container.makeSearchViewModel()
                )
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

                BookmarksView(
                    viewModel: container.makeBookmarkViewModel()
                )
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .accessibilityIdentifier("tab_bookmarks")
            }
        }
    }
}
