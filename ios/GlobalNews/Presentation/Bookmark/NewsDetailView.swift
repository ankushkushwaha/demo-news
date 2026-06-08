import SwiftUI

struct NewsDetailView: View {
    let urlString: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let url = URL(string: urlString) {
            SafariView(url: url) {
                dismiss()
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        } else {
            ContentUnavailableView(
                "Invalid URL",
                systemImage: "link.badge.xmark"
            )
        }
    }
}
