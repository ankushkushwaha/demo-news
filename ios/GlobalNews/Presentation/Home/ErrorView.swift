import SwiftUI

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
