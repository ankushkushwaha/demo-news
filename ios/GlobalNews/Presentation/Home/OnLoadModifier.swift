import SwiftUI

struct OnLoadModifier: ViewModifier {
    @State private var hasLoaded = false
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await action()
            }
    }
}

// MARK: - View Extension

extension View {
    func onLoad(perform action: @escaping () async -> Void) -> some View {
        modifier(OnLoadModifier(action: action))
    }
}
