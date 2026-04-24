import SwiftUI

struct AppButton: View {
    let title: String
    let variant: ButtonVariant
    let size: ButtonSize
    var isLoading: Bool = false
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary, outline, ghost, danger
    }

    enum ButtonSize: CGFloat {
        case large = 48
        case medium = 40
        case small = 32
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: .spaceXS) {
                if isLoading {
                    ProgressView()
                        .tint(variant == .primary || variant == .danger ? .white : .brandPrimary)
                }
                Text(title)
                    .font(size == .small ? .labelSmall : .label)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.rawValue)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                if variant == .outline {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.brandPrimary, lineWidth: 1)
                }
            }
            .opacity(isLoading ? 0.4 : (isPressed ? 0.7 : 1.0))
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .disabled(isLoading)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.appInstant) { isPressed = pressing }
        }, perform: {})
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: .brandPrimary
        case .secondary: .brandPrimaryLight
        case .outline, .ghost: .clear
        case .danger: .semanticError
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .danger: .white
        case .secondary, .outline, .ghost: .brandPrimary
        }
    }

    private var cornerRadius: CGFloat {
        size == .small ? .radiusXS : .radiusMD
    }
}
