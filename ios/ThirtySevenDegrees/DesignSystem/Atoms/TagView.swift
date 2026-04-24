import SwiftUI

struct TagView: View {
    let title: String
    @Binding var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelSmall)
                .foregroundStyle(isSelected ? .white : .textSecondary)
                .padding(.horizontal, .spaceMD)
                .frame(height: 28)
                .background(isSelected ? Color.brandPrimary : Color.bgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: .radiusXS))
        }
    }
}
