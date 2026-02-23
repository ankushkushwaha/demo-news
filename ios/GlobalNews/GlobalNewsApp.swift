
import SwiftUI

@main
struct GlobalNewsApp: App {
    @StateObject var container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: container.makeNewsViewModel()
            )
                .environmentObject(container)
        }
    }
}
