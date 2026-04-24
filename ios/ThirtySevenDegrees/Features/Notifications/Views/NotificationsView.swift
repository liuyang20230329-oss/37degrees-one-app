import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = NotificationItem.samples

    var body: some View {
        VStack(spacing: 0) {
            notificationList
        }
        .background(Color.bgPrimary)
        .navigationTitle("通知")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var notificationList: some View {
        List {
            ForEach(notifications) { item in
                NotificationRow(item: item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(item.isRead ? Color.bgPrimary : Color.brandPrimaryLight.opacity(0.3))
            }
        }
        .listStyle(.plain)
    }
}

struct NotificationItem: Identifiable {
    let id: String
    let type: NotificationType
    let username: String
    let avatarURL: URL?
    let content: String
    let timeAgo: String
    let isRead: Bool

    enum NotificationType {
        case like, comment, follow, mention, system
    }

    static var samples: [NotificationItem] {
        [
            NotificationItem(id: "1", type: .like, username: "用户A", avatarURL: nil, content: "赞了你的动态", timeAgo: "3分钟前", isRead: false),
            NotificationItem(id: "2", type: .comment, username: "用户B", avatarURL: nil, content: "评论了你的动态：太棒了！", timeAgo: "10分钟前", isRead: false),
            NotificationItem(id: "3", type: .follow, username: "用户C", avatarURL: nil, content: "关注了你", timeAgo: "1小时前", isRead: true),
            NotificationItem(id: "4", type: .mention, username: "用户D", avatarURL: nil, content: "在评论中提到了你", timeAgo: "2小时前", isRead: true),
            NotificationItem(id: "5", type: .system, username: "系统", avatarURL: nil, content: "你的动态已通过审核", timeAgo: "1天前", isRead: true),
        ]
    }
}

struct NotificationRow: View {
    let item: NotificationItem

    var body: some View {
        HStack(spacing: .spaceSM) {
            AvatarView(url: item.avatarURL, size: .md, placeholder: item.username)
            VStack(alignment: .leading, spacing: .spaceXXS) {
                HStack {
                    Text(item.username)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text(item.timeAgo)
                        .font(.captionSmall)
                        .foregroundStyle(.textTertiary)
                }
                Text(item.content)
                    .font(.bodySmall)
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
            }
            notificationIcon
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
    }

    @ViewBuilder
    private var notificationIcon: some View {
        switch item.type {
        case .like:
            Image(systemName: "heart.fill")
                .foregroundStyle(.brandPrimary)
        case .comment:
            Image(systemName: "bubble.left.fill")
                .foregroundStyle(.brandSecondary)
        case .follow:
            Image(systemName: "person.badge.plus")
                .foregroundStyle(.brandPrimary)
        case .mention:
            Image(systemName: "at")
                .foregroundStyle(.semanticInfo)
        case .system:
            Image(systemName: "bell.fill")
                .foregroundStyle(.semanticWarning)
        }
    }
}
