import SwiftUI

struct PostCard: View {
    let avatarURL: URL?
    let username: String
    let handle: String
    let timeAgo: String
    let content: String
    let tags: [String]
    let imageURLs: [URL]
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    let onMore: () -> Void
    let onAvatarTap: () -> Void
    let onTagTap: (String) -> Void

    @State private var showLikeAnimation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if !content.isEmpty { contentSection }
            if !imageURLs.isEmpty { mediaSection }
            actionBar
        }
        .background(Color.bgPrimary)
    }

    private var header: some View {
        HStack(spacing: .spaceSM) {
            AvatarView(url: avatarURL, size: .lg, placeholder: username)
                .onTapGesture { onAvatarTap() }

            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                HStack(spacing: .spaceXS) {
                    Text("@\(handle)")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                    Text("·")
                        .foregroundStyle(.textTertiary)
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: .spaceXS) {
            Text(content)
                .font(.bodyMedium)
                .foregroundStyle(.textPrimary)
                .lineLimit(6)

            if !tags.isEmpty {
                HStack(spacing: .spaceXS) {
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundStyle(.brandPrimary)
                            .onTapGesture { onTagTap(tag) }
                    }
                }
            }
        }
        .padding(.horizontal, .spaceLG)
        .padding(.bottom, .spaceSM)
    }

    @ViewBuilder
    private var mediaSection: some View {
        MediaGrid(imageURLs: imageURLs)
            .padding(.horizontal, .spaceLG)
            .padding(.bottom, .spaceSM)
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likeCount,
                color: isLiked ? .brandPrimary : .textTertiary,
                action: onLike
            )
            actionButton(
                icon: "bubble.left",
                count: commentCount,
                color: .textTertiary,
                action: onComment
            )
            actionButton(
                icon: "square.and.arrow.up",
                count: nil,
                color: .textTertiary,
                action: onShare
            )
            Spacer()
            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.system(size: IconSize.md.rawValue))
                    .foregroundStyle(.textTertiary)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, .spaceLG)
        .frame(height: 44)
    }

    private func actionButton(icon: String, count: Int?, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: .spaceXXS) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.md.rawValue))
                    .foregroundStyle(color)
                if let count {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
            }
        }
        .frame(height: 44)
    }
}

struct MediaGrid: View {
    let imageURLs: [URL]

    var body: some View {
        let cols = gridColumns
        LazyVGrid(columns: cols, spacing: 2) {
            ForEach(imageURLs, id: \.self) { url in
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Rectangle().fill(Color.bgTertiary)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
            }
        }
    }

    private var gridColumns: [GridItem] {
        switch imageURLs.count {
        case 1: return [GridItem(.flexible())]
        case 2: return [GridItem(.flexible()), GridItem(.flexible())]
        default: return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }
}
