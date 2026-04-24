import SwiftUI

struct AppNavigationBar: View {
    let title: String
    var onBack: (() -> Void)? = nil
    var rightActions: [NavigationBarAction] = []

    struct NavigationBarAction {
        let iconName: String
        let action: () -> Void
    }

    var body: some View {
        HStack {
            if let onBack {
                AppIconButton(iconName: "chevron.left", action: onBack)
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            Spacer()

            HStack(spacing: .spaceXS) {
                ForEach(rightActions.indices, id: \.self) { index in
                    AppIconButton(iconName: rightActions[index].iconName, action: rightActions[index].action)
                }
                if rightActions.isEmpty {
                    Spacer().frame(width: 44)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, .spaceLG)
    }
}
