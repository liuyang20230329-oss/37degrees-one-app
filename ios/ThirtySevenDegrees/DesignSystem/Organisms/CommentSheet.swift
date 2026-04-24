import SwiftUI

struct CommentSheet: View {
    let commentCount: Int
    @Binding var isPresented: Bool
    @State private var commentText = ""
    @State private var sortMode: CommentSort = .hot

    enum CommentSort: String, CaseIterable {
        case hot = "热门"
        case latest = "最新"
    }

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            titleBar
            sortTabs
            commentList
            inputBar
        }
        .background(Color.bgPrimary)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: .radiusXL, topTrailingRadius: .radiusXL))
    }

    private var handleBar: some View {
        Capsule()
            .fill(Color.dividerColor)
            .frame(width: 36, height: 4)
            .padding(.top, .spaceSM)
            .padding(.bottom, .spaceXS)
    }

    private var titleBar: some View {
        HStack {
            Text("评论 \(commentCount)")
                .font(.headline)
                .foregroundStyle(.textPrimary)
            Spacer()
            AppIconButton(iconName: "xmark") {
                withAnimation(.appNormal) { isPresented = false }
            }
        }
        .padding(.horizontal, .spaceLG)
        .frame(height: 44)
    }

    private var sortTabs: some View {
        HStack(spacing: .spaceMD) {
            ForEach(CommentSort.allCases, id: \.self) { sort in
                Button { withAnimation(.appFast) { sortMode = sort } } label: {
                    HStack(spacing: .spaceXXS) {
                        Text(sort.rawValue)
                            .font(.bodySmall)
                            .foregroundStyle(sortMode == sort ? .brandPrimary : .textSecondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: IconSize.xs.rawValue))
                            .foregroundStyle(.textTertiary)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, .spaceLG)
        .frame(height: 36)
    }

    private var commentList: some View {
        ScrollView {
            LazyVStack(spacing: .spaceMD) {
                ForEach(0..<20, id: \.self) { _ in
                    CommentItemPlaceholder()
                }
            }
            .padding(.horizontal, .spaceLG)
        }
    }

    private var inputBar: some View {
        HStack(spacing: .spaceSM) {
            AvatarView(url: nil, size: .sm, placeholder: "我")
            TextField("说点什么...", text: $commentText)
                .font(.bodyMedium)
            AppIconButton(iconName: "face.smiling") {}
            AppIconButton(iconName: "photo.on.rectangle") {}
            AppIconButton(iconName: "at") {}
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
        .frame(height: 56)
        .background(Color.bgPrimary)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.dividerColor).frame(height: 0.5)
        }
    }
}

private struct CommentItemPlaceholder: View {
    var body: some View {
        HStack(alignment: .top, spacing: .spaceSM) {
            AvatarView(url: nil, size: .sm, placeholder: "U")
            VStack(alignment: .leading, spacing: .spaceXS) {
                Text("用户名")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                Text("这是一条评论内容示例")
                    .font(.bodySmall)
                    .foregroundStyle(.textPrimary)
                HStack(spacing: .spaceMD) {
                    Text("2小时前")
                        .font(.captionSmall)
                        .foregroundStyle(.textTertiary)
                    Button("回复") {}
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer()
            Button {} label: {
                VStack(spacing: 2) {
                    Image(systemName: "heart")
                        .font(.system(size: IconSize.sm.rawValue))
                    Text("12")
                        .font(.captionSmall)
                }
                .foregroundStyle(.textTertiary)
            }
        }
    }
}
