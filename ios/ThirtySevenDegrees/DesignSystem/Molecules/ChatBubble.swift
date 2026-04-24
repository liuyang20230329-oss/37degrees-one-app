import SwiftUI

struct ChatBubble: View {
    let message: String
    let isOwn: Bool
    let time: String
    var showAvatar: Bool = true
    var avatarURL: URL? = nil
    var senderName: String = ""

    var body: some View {
        HStack(alignment: .bottom, spacing: .spaceSM) {
            if !isOwn && showAvatar {
                AvatarView(url: avatarURL, size: .xs, placeholder: senderName)
            }

            VStack(alignment: isOwn ? .trailing : .leading, spacing: 2) {
                bubble
                Text(time)
                    .font(.captionSmall)
                    .foregroundStyle(.textTertiary)
            }

            if isOwn {
                Spacer(minLength: 30)
            }
        }
        .padding(.horizontal, .spaceLG)
    }

    private var bubble: some View {
        Text(message)
            .font(.bodyMedium)
            .foregroundStyle(isOwn ? .white : .textPrimary)
            .padding(.horizontal, .spaceMD)
            .padding(.vertical, .spaceSM)
            .background(isOwn ? Color.brandPrimary : Color.bgTertiary)
            .clipShape(bubbleShape)
            .frame(maxWidth: .infinity, alignment: isOwn ? .trailing : .leading)
            .modifier(MaxWidthModifier(ratio: 0.7))
    }

    private var bubbleShape: some Shape {
        let radii = isOwn
            ? UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 12)
            : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 4)
        return CustomCornerRadiusShape(radii: radii)
    }
}

struct CustomCornerRadiusShape: Shape {
    let radii: UIEdgeInsets

    func path(in rect: CGRect) -> Path {
        let topLeft = radii.left
        let topRight = radii.right
        let bottomLeft = radii.left
        let bottomRight = radii.right

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        return path
    }
}

struct MaxWidthModifier: ViewModifier {
    let ratio: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content.frame(maxWidth: geo.size.width * ratio, alignment: .leading)
        }
    }
}
