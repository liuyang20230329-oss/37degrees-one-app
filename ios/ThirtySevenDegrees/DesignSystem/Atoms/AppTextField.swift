import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var variant: TextFieldVariant = .filled
    var errorMessage: String? = nil
    var maxLength: Int? = nil
    var isSecure: Bool = false

    enum TextFieldVariant {
        case filled, outlined
    }

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .spaceXS) {
            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.bodyMedium)
                .foregroundStyle(.textPrimary)
                .focused($isFocused)

                if let maxLength {
                    Text("\(text.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
            }
            .padding(.horizontal, .spaceMD)
            .frame(height: 44)
            .background(variant == .filled ? Color.bgTertiary : .clear)
            .clipShape(RoundedRectangle(cornerRadius: .radiusSM))
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSM)
                    .stroke(borderColor, lineWidth: variant == .outlined || isFocused ? 1.5 : 0)
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.semanticError)
            }
        }
    }

    private var borderColor: Color {
        if let errorMessage { return .semanticError }
        if isFocused { return .brandPrimary }
        if variant == .outlined { return .borderColor }
        return .clear
    }
}
