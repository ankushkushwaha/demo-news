
import SwiftUI

@main
struct GlobalNewsApp: App {
    @StateObject var container = AppContainer()
    @StateObject var router = Router()

    var body: some Scene {
        WindowGroup {
            AppMainContainerView()
                .environmentObject(container)
                .environmentObject(router)
        }
    }
}
