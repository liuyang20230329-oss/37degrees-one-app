import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: .spaceMD) {
            Spacer().frame(height: .spaceXXXL)

            Image(systemName: "tray")
                .font(.system(size: IconSize.xxl.rawValue))
                .foregroundStyle(.textTertiary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.textSecondary)

            Text(subtitle)
                .font(.bodySmall)
                .foregroundStyle(.textTertiary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                AppButton(title: actionTitle, variant: .secondary, size: .medium, action: action)
                    .frame(width: 120)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, .spaceXXL)
    }
}
