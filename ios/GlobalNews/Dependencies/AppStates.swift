
final class AppStates {
    /// Shared states

    let bookmarkStore: BookmarkStore
    
    init(
        bookmarkStore: BookmarkStore = PersistentBookmarkStore()
    ) {
        self.bookmarkStore = bookmarkStore
    }
}
