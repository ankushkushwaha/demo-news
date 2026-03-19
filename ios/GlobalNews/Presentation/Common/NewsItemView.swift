import SwiftUI

struct NewsItemView: View {
    let item: NewsItem
    let isBookmarked: Bool
    let onBookmarkTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(item.title)
                    .font(.custom("Georgia", size: 16).weight(.semibold))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: onBookmarkTap) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }

            if !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 6) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 10))
                Text(item.source)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text(item.pubDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.orange)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}
