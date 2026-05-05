import SwiftUI

struct NewsDetailView: View {
    let urlString: String
    
    var body: some View {
        if let url = URL(string: urlString) {
            SafariView(url: url)
                .ignoresSafeArea()
        } else {
            ContentUnavailableView(
                "Invalid URL",
                systemImage: "link.badge.xmark"
            )
        }
    }
}
