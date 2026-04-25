import SwiftUI

struct AppShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let none = AppShadow(color: .clear, radius: 0, x: 0, y: 0)
    static let sm = AppShadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    static let md = AppShadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
    static let lg = AppShadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 4)
    static let xl = AppShadow(color: .black.opacity(0.20), radius: 32, x: 0, y: 8)
}

extension View {
    func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

struct CardShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content.overlay(
                RoundedRectangle(cornerRadius: .radiusMD)
                    .stroke(Color.borderColor, lineWidth: 0.5)
            )
        } else {
            content.appShadow(.sm)
        }
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }
}
