import Combine
import SwiftUI

final class Router: ObservableObject {
    
    enum Route: Hashable {
        case detail(String)
        case setting
    }
    
    @Published var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pushToRoot() {
        path = NavigationPath()
    }
    
    func pop() {
        path.removeLast()
    }
}
