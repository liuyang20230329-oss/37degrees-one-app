import SwiftUI

struct ProfileView: View {
    @State private var isOwnProfile = true
    @State private var selectedTab = 0
    let tabs = ["动态", "相册", "收藏"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                statsRow
                actionButtons
                contentTabs
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的")
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AppIconButton(iconName: "gearshape") {}
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: .spaceMD) {
            AvatarView(url: nil, size: .xxl, placeholder: "我")
            VStack(spacing: .spaceXS) {
                Text("用户名")
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                Text("@username")
                    .font(.bodySmall)
                    .foregroundStyle(.textTertiary)
                Text("这是个人简介，分享生活中的点滴")
                    .font(.bodySmall)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .spaceXXL)
            }
        }
        .padding(.top, .spaceXXL)
        .padding(.bottom, .spaceLG)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(count: 128, label: "关注")
            Rectangle().fill(Color.dividerColor).frame(width: 0.5, height: 30)
            statItem(count: 256, label: "粉丝")
            Rectangle().fill(Color.dividerColor).frame(width: 0.5, height: 30)
            statItem(count: 1024, label: "获赞")
        }
        .padding(.vertical, .spaceMD)
    }

    private func statItem(count: Int, label: String) -> some View {
        VStack(spacing: .spaceXXS) {
            Text("\(count)")
                .font(.headline)
                .foregroundStyle(.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: .spaceSM) {
            AppButton(title: "编辑资料", variant: .outline, size: .medium, action: {})
            AppButton(title: "分享", variant: .ghost, size: .medium, action: {})
        }
        .padding(.horizontal, .spaceLG)
        .padding(.bottom, .spaceLG)
    }

    private var contentTabs: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button {
                        withAnimation(.appFast) { selectedTab = index }
                    } label: {
                        VStack(spacing: .spaceXS) {
                            Text(tabs[index])
                                .font(selectedTab == index ? .labelSmall : .bodySmall)
                                .foregroundStyle(selectedTab == index ? .textPrimary : .textTertiary)
                            Rectangle()
                                .fill(selectedTab == index ? Color.brandPrimary : .clear)
                                .frame(height: 2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, .spaceLG)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                ForEach(1...9, id: \.self) { i in
                    Rectangle()
                        .fill(Color.bgTertiary)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: .radiusXS))
                }
            }
            .padding(.spaceLG)
        }
    }
}
