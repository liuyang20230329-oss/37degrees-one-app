import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()
    @State private var showLogoutConfirm = false
    @State private var showCancelConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: .spaceLG) {
                privacySection
                notificationSection
                accountSection
                dangerZone
            }
            .padding(.horizontal, .spaceLG)
            .padding(.bottom, 40)
        }
        .background(Color.bgPrimary)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadSettings() }
    }

    private var privacySection: some View {
        settingsGroup(title: "隐私设置") {
            ToggleRow(
                title: "仅好友可聊",
                subtitle: "开启后只有好友能发起私聊",
                isOn: Binding(
                    get: { viewModel.settings?.friendsOnly ?? false },
                    set: { newValue in
                        viewModel.settings?.friendsOnly = newValue
                        Task { await saveSettings() }
                    }
                )
            )

            ToggleRow(
                title: "广场曝光",
                subtitle: "允许你的资料在广场被推荐",
                isOn: Binding(
                    get: { viewModel.settings?.allowSquareExposure ?? true },
                    set: { newValue in
                        viewModel.settings?.allowSquareExposure = newValue
                        Task { await saveSettings() }
                    }
                )
            )

            ToggleRow(
                title: "优先已认证用户",
                subtitle: "推荐列表优先展示已认证用户",
                isOn: Binding(
                    get: { viewModel.settings?.preferVerifiedUsers ?? true },
                    set: { newValue in
                        viewModel.settings?.preferVerifiedUsers = newValue
                        Task { await saveSettings() }
                    }
                )
            )
        }
    }

    private var notificationSection: some View {
        settingsGroup(title: "通知设置") {
            SettingsRow(title: "通知中心", icon: "bell", showChevron: true) {
                NavigationLink(value: AppRoute.notifications) {
                    EmptyView()
                }
            }
            SettingsRow(title: "设备管理", icon: "laptopcomputer.and.iphone", showChevron: true) {
                EmptyView()
            }
        }
    }

    private var accountSection: some View {
        settingsGroup(title: "账号安全") {
            SettingsRow(title: "黑名单", icon: "hand.raised", showChevron: true) {
                EmptyView()
            }
            SettingsRow(title: "修改密码", icon: "lock", showChevron: true) {
                EmptyView()
            }
        }
    }

    private var dangerZone: some View {
        VStack(spacing: .spaceSM) {
            AppButton(title: "退出登录", variant: .outline, size: .medium) {
                showLogoutConfirm = true
            }
            .alert("确认退出", isPresented: $showLogoutConfirm) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) { performLogout() }
            } message: {
                Text("退出后需要重新登录")
            }

            Button {
                showCancelConfirm = true
            } label: {
                Text("注销账号")
                    .font(.bodySmall)
                    .foregroundStyle(.semanticError)
            }
            .alert("确认注销", isPresented: $showCancelConfirm) {
                Button("取消", role: .cancel) {}
                Button("注销", role: .destructive) { Task { await performCancelAccount() } }
            } message: {
                Text("注销后账号将在冷静期后永久删除，此操作不可恢复")
            }
        }
        .padding(.top, .spaceXL)
    }

    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.textTertiary)
                .padding(.horizontal, .spaceXS)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
        }
    }

    private func saveSettings() async {
        guard let settings = viewModel.settings else { return }
        await viewModel.saveSettings(settings)
    }

    private func performLogout() {
        AuthService.shared.clearSession()
    }

    private func performCancelAccount() async {
        guard AuthService.shared.isAuthenticated else { return }
        AuthService.shared.clearSession()
    }
}

struct SettingsRow<Destination: View>: View {
    let title: String
    let icon: String
    let showChevron: Bool
    let destination: () -> Destination

    var body: some View {
        Button {
            let _ = destination()
        } label: {
            HStack(spacing: .spaceMD) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.sm.rawValue))
                    .foregroundStyle(.brandPrimary)
                    .frame(width: 24)

                Text(title)
                    .font(.bodyMedium)
                    .foregroundStyle(.textPrimary)

                Spacer()

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
            }
            .padding(.horizontal, .spaceLG)
            .frame(height: 48)
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.textTertiary)
                    }
                }
            }
            .tint(.brandPrimary)
        }
        .padding(.horizontal, .spaceLG)
        .padding(.vertical, .spaceSM)
    }
}
