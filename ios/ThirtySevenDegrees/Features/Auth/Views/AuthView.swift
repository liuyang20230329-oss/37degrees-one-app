import SwiftUI

struct AuthView: View {
    let onLoginSuccess: () -> Void
    @State private var isSignUp = false
    @State private var phone = ""
    @State private var verificationCode = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spaceXXL) {
                    header
                    if isSignUp { signUpFields } else { signInFields }
                    actionButton
                    toggleButton
                    socialLogin
                }
                .padding(.horizontal, .spaceLG)
                .padding(.top, .spaceXXXL * 2)
            }
            .background(Color.bgPrimary)
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        VStack(spacing: .spaceSM) {
            Text("37°")
                .font(.displayLarge)
                .foregroundStyle(.brandPrimary)
            Text("温度与信任")
                .font(.bodyMedium)
                .foregroundStyle(.textSecondary)
        }
    }

    private var signInFields: some View {
        VStack(spacing: .spaceMD) {
            AppTextField(placeholder: "手机号", text: $phone, maxLength: 11)
            AppTextField(placeholder: "密码", text: $password, isSecure: true)
        }
    }

    private var signUpFields: some View {
        VStack(spacing: .spaceMD) {
            AppTextField(placeholder: "手机号", text: $phone, maxLength: 11)
            HStack(spacing: .spaceSM) {
                AppTextField(placeholder: "验证码", text: $verificationCode, maxLength: 6)
                    .frame(maxWidth: .infinity)
                AppButton(title: "获取验证码", variant: .outline, size: .small, action: {})
                    .frame(width: 110)
            }
            AppTextField(placeholder: "密码", text: $password, isSecure: true)
            AppTextField(placeholder: "昵称", text: $nickname, maxLength: 20)
        }
    }

    private var actionButton: some View {
        AppButton(
            title: isSignUp ? "注册" : "登录",
            variant: .primary,
            size: .large,
            isLoading: isLoading,
            action: { onLoginSuccess() }
        )
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.appFast) { isSignUp.toggle() }
        } label: {
            HStack(spacing: .spaceXXS) {
                Text(isSignUp ? "已有账号？" : "没有账号？")
                    .font(.bodySmall)
                    .foregroundStyle(.textSecondary)
                Text(isSignUp ? "去登录" : "立即注册")
                    .font(.bodySmall)
                    .foregroundStyle(.brandPrimary)
            }
        }
    }

    private var socialLogin: some View {
        VStack(spacing: .spaceLG) {
            HStack {
                Rectangle().fill(Color.dividerColor).frame(height: 0.5)
                Text("其他登录方式")
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
                    .layoutPriority(1)
                Rectangle().fill(Color.dividerColor).frame(height: 0.5)
            }

            HStack(spacing: .spaceXXXL) {
                socialButton(icon: "message.fill", label: "微信")
                socialButton(icon: "phone.fill", label: "Apple")
            }
        }
        .padding(.top, .spaceXL)
    }

    private func socialButton(icon: String, label: String) -> some View {
        Button {} label: {
            VStack(spacing: .spaceXS) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.lg.rawValue))
                    .foregroundStyle(.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(Color.bgTertiary)
                    .clipShape(Circle())
                Text(label)
                    .font(.captionSmall)
                    .foregroundStyle(.textTertiary)
            }
        }
    }
}
