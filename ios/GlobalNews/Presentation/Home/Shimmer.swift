
import SwiftUI
import Combine

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.85), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(20))
                    .offset(x: phase * 400)
                    .blendMode(.overlay)
                    .onAppear {
                        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}
