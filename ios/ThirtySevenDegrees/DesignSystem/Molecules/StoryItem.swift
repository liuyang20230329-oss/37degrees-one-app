import SwiftUI

struct StoryItem: View {
    let avatarURL: URL?
    let username: String
    let isViewed: Bool
    let isMine: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spaceXS) {
                ZStack(alignment: .topLeading) {
                    Circle()
                        .stroke(
                            isViewed ? Color.dividerColor : LinearGradient(
                                colors: [.brandPrimary, .brandSecondary],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 76, height: 76)

                    AvatarView(url: avatarURL, size: .lg, placeholder: username)
                        .offset(x: 14, y: 14)

                    if isMine {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.brandPrimary, .bgPrimary)
                            .offset(x: 50, y: 50)
                    }
                }

                Text(username)
                    .font(.caption)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 76)
        }
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var storyGradient: LinearGradient {
        LinearGradient(
            colors: [Color.brandPrimary, Color.brandSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Shape {
    func stroke(_ gradient: LinearGradient, lineWidth: CGFloat) -> some View {
        self.overlay(
            self.stroke(gradient, lineWidth: lineWidth)
        )
    }
}
