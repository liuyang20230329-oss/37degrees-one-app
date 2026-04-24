import SwiftUI

struct SearchBar: View {
    let placeholder: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .spaceSM) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: IconSize.sm.rawValue))
                    .foregroundStyle(.textTertiary)

                Text(placeholder)
                    .font(.bodySmall)
                    .foregroundStyle(.textTertiary)

                Spacer()
            }
            .padding(.horizontal, .spaceMD)
            .frame(height: 40)
            .background(Color.bgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
        }
    }
}
