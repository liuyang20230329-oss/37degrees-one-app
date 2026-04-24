import SwiftUI

struct AppIconButton: View {
    let iconName: String
    var tint: Color = .textPrimary
    var showBackground: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: IconSize.md.rawValue))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(showBackground ? Color.bgTertiary : .clear)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .opacity(isPressed ? 0.6 : 1.0)
        }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.appInstant) { isPressed = pressing }
        }, perform: {})
    }
}
