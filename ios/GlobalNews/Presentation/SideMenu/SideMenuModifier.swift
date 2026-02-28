import SwiftUI

struct SideMenuModifier: ViewModifier {
    @State private var isOpen = false
    @EnvironmentObject var router: Router

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content.disabled(isOpen)
            if isOpen {
                SideMenuView(isOpen: $isOpen) { item in
                    if item.title == "Settings" { router.push(.setting) }
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isOpen)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { isOpen.toggle() } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
        }
        .gesture(DragGesture().onEnded { value in
            if value.translation.width > 80 { isOpen = true }
            else if value.translation.width < -80 { isOpen = false }
        })
    }
}

extension View {
    func withSideMenu() -> some View {
        modifier(SideMenuModifier())
    }
}
