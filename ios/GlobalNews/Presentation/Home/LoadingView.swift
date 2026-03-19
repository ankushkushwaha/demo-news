import SwiftUI

struct LoadingView: View {
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let cardHeight: CGFloat = 110
            let spacing: CGFloat = 12
            let count = max(1, Int(geo.size.height / (cardHeight + spacing)))

            VStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { i in
                    SkeletonCardView()
                        .padding(.horizontal, 16)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 22)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.72)
                                .delay(Double(i) * 0.09 + 0.15),
                            value: appeared
                        )
                }
                Spacer()
            }
        }
        .onAppear { appeared = true }
    }
}
struct SkeletonCardView: View {
    private func bar(_ color: UIColor, width: CGFloat? = nil, height: CGFloat, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color(color))
            .frame(maxWidth: width ?? .infinity)
            .frame(height: height)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            bar(.systemGray5, height: 14, radius: 5)
            bar(.systemGray5, width: 260, height: 14, radius: 5)
            bar(.systemGray5, width: 180, height: 14, radius: 5)

            Spacer().frame(height: 2)

            bar(.systemGray6, height: 11, radius: 4)
            bar(.systemGray6, width: 220, height: 11, radius: 4)

            Spacer().frame(height: 2)

            HStack {
                bar(.systemGray5, width: 80, height: 10, radius: 4)
                Spacer()
                bar(.systemGray5, width: 50, height: 10, radius: 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .shimmer()
    }
}
