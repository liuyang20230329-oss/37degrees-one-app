import SwiftUI

struct AvatarView: View {
    let url: URL?
    let size: AvatarSize
    let placeholder: String
    var showOnlineIndicator: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    ZStack {
                        Circle().fill(Color.bgTertiary)
                        Text(String(placeholder.prefix(1)))
                            .font(.system(size: size.rawValue * 0.4, weight: .medium))
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            .frame(width: size.rawValue, height: size.rawValue)
            .clipShape(Circle())

            if showOnlineIndicator {
                Circle()
                    .fill(Color.semanticSuccess)
                    .frame(width: size.rawValue * 0.25, height: size.rawValue * 0.25)
                    .overlay(Circle().stroke(Color.bgPrimary, lineWidth: 2))
            }
        }
    }
}
