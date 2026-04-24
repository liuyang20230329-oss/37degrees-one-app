import SwiftUI

struct BadgeView: View {
    let style: BadgeStyle

    enum BadgeStyle {
        case dot
        case count(Int)
        case text(String)
    }

    var body: some View {
        switch style {
        case .dot:
            Circle()
                .fill(Color.brandAccent)
                .frame(width: 8, height: 8)

        case .count(let value):
            let display = value > 99 ? "99+" : "\(value)"
            Text(display)
                .font(.labelTiny)
                .foregroundStyle(.white)
                .padding(.horizontal, value > 9 ? 6 : 0)
                .frame(minWidth: 16, minHeight: 16)
                .background(Color.brandAccent)
                .clipShape(Capsule())

        case .text(let label):
            Text(label)
                .font(.labelTiny)
                .foregroundStyle(.white)
                .padding(.horizontal, .spaceSM)
                .frame(height: 20)
                .background(Color.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: .radiusXS))
        }
    }
}
