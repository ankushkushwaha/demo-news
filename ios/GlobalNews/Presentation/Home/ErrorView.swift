import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: (() -> Void)?
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .accessibilityIdentifier("error_message_label")

            Button("Retry") {
                retry?()
            }
            .accessibilityIdentifier("error_retry_button")
        }
    }
}
