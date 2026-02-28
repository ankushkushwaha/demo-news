import SwiftUI

struct SideMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct SideMenuView: View {
    @Binding var isOpen: Bool
    let onItemTap: (SideMenuItem) -> Void

    private let items: [SideMenuItem] = [
        SideMenuItem(title: "Home", icon: "house"),
        SideMenuItem(title: "Bookmarks", icon: "bookmark"),
        SideMenuItem(title: "Settings", icon: "gearshape")
    ]

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider().padding(.vertical, 20)
                itemList
                Spacer()
            }
            .frame(width: 270)
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground))
            .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { isOpen = false }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("GlobalNews")
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("Your world, at a glance")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 68)
        .padding(.horizontal, 20)
    }

    private var itemList: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    isOpen = false
                    onItemTap(item)
                } label: {
                    Label(item.title, systemImage: item.icon)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
                .buttonStyle(.plain)
            }
        }
    }
}
