import SwiftUI

struct ChatListView: View {
    @State private var searchText = ""
    @State private var conversations: [ConversationItem] = ConversationItem.samples

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            conversationList
        }
        .background(Color.bgPrimary)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("消息")
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AppIconButton(iconName: "square.and.pencil") {}
            }
        }
    }

    private var searchBar: some View {
        SearchBar(placeholder: "搜索") {}
            .padding(.horizontal, .spaceLG)
            .padding(.vertical, .spaceSM)
    }

    private var conversationList: some View {
        List {
            ForEach(conversations) { convo in
                ConversationRow(conversation: convo)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onTapGesture {}
            }
        }
        .listStyle(.plain)
    }
}

struct ConversationItem: Identifiable {
    let id: String
    let username: String
    let avatarURL: URL?
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int
    let isPinned: Bool

    static var samples: [ConversationItem] {
        (1...10).map { i in
            ConversationItem(
                id: "\(i)",
                username: i == 1 ? "37度小助手" : "用户\(i)",
                avatarURL: nil,
                lastMessage: "这是最后一条消息的预览内容...",
                timeAgo: "\(i)分钟前",
                unreadCount: i <= 3 ? i : 0,
                isPinned: i == 1
            )
        }
    }
}

struct ConversationRow: View {
    let conversation: ConversationItem

    var body: some View {
        HStack(spacing: .spaceSM) {
            AvatarView(url: conversation.avatarURL, size: .lg, placeholder: conversation.username)

            VStack(alignment: .leading, spacing: .spaceXS) {
                HStack {
                    Text(conversation.username)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text(conversation.timeAgo)
                        .font(.captionSmall)
                        .foregroundStyle(.textTertiary)
                }
                HStack {
                    Text(conversation.lastMessage)
                        .font(.bodySmall)
                        .foregroundStyle(.textTertiary)
                        .lineLimit(1)
                    Spacer()
                    if conversation.unreadCount > 0 {
                        BadgeView(style: .count(conversation.unreadCount))
                    }
                }
            }
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
        .background(conversation.isPinned ? Color.bgSecondary : Color.bgPrimary)
    }
}
