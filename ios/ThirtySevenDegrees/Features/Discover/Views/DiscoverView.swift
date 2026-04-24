import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var selectedTag = "全部"
    let tags = ["全部", "热门", "附近", "话题", "用户", "视频"]

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(placeholder: "搜索用户、话题、内容...") {}
                .padding(.horizontal, .spaceLG)
                .padding(.vertical, .spaceSM)

            tagFilter
            contentArea
        }
        .background(Color.bgPrimary)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("发现")
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
            }
        }
    }

    private var tagFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .spaceSM) {
                ForEach(tags, id: \.self) { tag in
                    TagView(title: tag, isSelected: .constant(tag == selectedTag)) {
                        withAnimation(.appFast) { selectedTag = tag }
                    }
                }
            }
            .padding(.horizontal, .spaceLG)
        }
        .padding(.bottom, .spaceSM)
    }

    private var contentArea: some View {
        ScrollView {
            LazyVStack(spacing: .spaceMD) {
                hotTopics
                nearbyPeople
                recommendedUsers
            }
            .padding(.horizontal, .spaceLG)
        }
    }

    private var hotTopics: some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            Text("热门话题")
                .font(.displaySmall)
                .foregroundStyle(.textPrimary)

            ForEach(1...5, id: \.self) { i in
                HStack {
                    Text("\(i)")
                        .font(.labelSmall)
                        .foregroundStyle(i <= 3 ? .brandPrimary : .textTertiary)
                    Text("#热门话题\(i)")
                        .font(.bodyMedium)
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text("\(i * 100)讨论")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
                .padding(.vertical, .spaceXS)
            }
        }
        .padding(.spaceMD)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
    }

    private var nearbyPeople: some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            Text("附近的人")
                .font(.displaySmall)
                .foregroundStyle(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: .spaceSM) {
                    ForEach(1...6, id: \.self) { i in
                        VStack(spacing: .spaceXS) {
                            AvatarView(url: nil, size: .xl, placeholder: "用\(i)")
                            Text("用户\(i)")
                                .font(.caption)
                                .foregroundStyle(.textPrimary)
                            Text("\(i)km")
                                .font(.captionSmall)
                                .foregroundStyle(.textTertiary)
                        }
                    }
                }
            }
        }
        .padding(.spaceMD)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
    }

    private var recommendedUsers: some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            Text("推荐用户")
                .font(.displaySmall)
                .foregroundStyle(.textPrimary)

            ForEach(1...5, id: \.self) { i in
                HStack(spacing: .spaceSM) {
                    AvatarView(url: nil, size: .md, placeholder: "用\(i)")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("推荐用户\(i)")
                            .font(.bodyMedium)
                            .foregroundStyle(.textPrimary)
                        Text("这是用户简介...")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    AppButton(title: "关注", variant: .secondary, size: .small, action: {})
                        .frame(width: 70)
                }
                .padding(.vertical, .spaceXS)
            }
        }
        .padding(.spaceMD)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
    }
}
