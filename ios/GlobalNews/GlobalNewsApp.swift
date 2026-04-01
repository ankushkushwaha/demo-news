
import SwiftUI

@main
struct GlobalNewsApp: App {
    @StateObject private var container = AppContainerFactory.makeContainer()
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            AppMainContainerView()
                .environmentObject(container)
                .environmentObject(router)
        }
    }
}
