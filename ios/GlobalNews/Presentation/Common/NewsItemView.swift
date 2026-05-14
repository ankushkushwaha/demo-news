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
                    .dynamicTypeSize(.large ... .accessibility5)
                    .accessibilityLabel("\(item.title)")
                    .accessibilityHint("Click to open news article's detail")

                Spacer()

                Button(action: onBookmarkTap) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.orange)
                        .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")
                        .accessibilityHint("Double tap to \(isBookmarked ? "remove" : "add") this article from bookmarks")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("bookmark_\(item.id)")
                .accessibilityAddTraits(.isButton)
            }

            if !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .dynamicTypeSize(.medium ... .accessibility5)
            }

            HStack(spacing: 6) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 10))
                    .accessibilityHidden(true)

                Text(item.source)
                    .font(.system(size: 12, weight: .medium))
                    .accessibilityLabel("Source: \(item.source)")

                Spacer()

                Text(item.pubDate.relativeDisplayString)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Published: \(item.pubDate.relativeDisplayString)")
            }
            .foregroundColor(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .contain)
    }
}
