import SwiftUI

struct FeedView: View {
    @State private var selectedSegment = 0
    @State private var showCommentSheet = false

    var body: some View {
        VStack(spacing: 0) {
            segmentControl
            storiesRow
            feedList
        }
        .background(Color.bgPrimary)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("首页")
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
            }
        }
    }

    private var segmentControl: some View {
        HStack(spacing: 0) {
            segmentButton(title: "推荐", index: 0)
            segmentButton(title: "关注", index: 1)
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
    }

    private func segmentButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.appFast) { selectedSegment = index }
        } label: {
            VStack(spacing: .spaceXS) {
                Text(title)
                    .font(selectedSegment == index ? .headline : .bodyMedium)
                    .foregroundStyle(selectedSegment == index ? .textPrimary : .textTertiary)
                Rectangle()
                    .fill(selectedSegment == index ? Color.brandPrimary : .clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var storiesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .spaceSM) {
                StoryItem(avatarURL: nil, username: "我的", isViewed: false, isMine: true, onTap: {})
                ForEach(1...8, id: \.self) { i in
                    StoryItem(avatarURL: nil, username: "用户\(i)", isViewed: i > 4, isMine: false, onTap: {})
                }
            }
            .padding(.horizontal, .spaceLG)
        }
        .padding(.vertical, .spaceSM)
    }

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(1...10, id: \.self) { i in
                    PostCard(
                        avatarURL: nil,
                        username: "用户\(i)",
                        handle: "user\(i)",
                        timeAgo: "\(i)分钟前",
                        content: "这是第\(i)条动态内容，分享生活中的美好瞬间 #日常 #分享",
                        tags: ["日常", "分享"],
                        imageURLs: [],
                        likeCount: i * 12,
                        commentCount: i * 3,
                        isLiked: i % 3 == 0,
                        onLike: {},
                        onComment: { showCommentSheet = true },
                        onShare: {},
                        onMore: {},
                        onAvatarTap: {},
                        onTagTap: { _ in }
                    )
                    Divider().background(Color.dividerColor)
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentSheet(commentCount: 238, isPresented: $showCommentSheet)
                .presentationDetents([.medium, .large])
        }
    }
}
