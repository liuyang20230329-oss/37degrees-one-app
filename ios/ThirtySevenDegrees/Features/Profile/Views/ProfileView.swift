import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    let tabs = ["动态", "相册", "收藏"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                progressSection
                verificationSection
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
                NavigationLink(value: AppRoute.settings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: IconSize.md.rawValue))
                        .foregroundStyle(.textPrimary)
                }
            }
        }
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadProfile() }
        .overlay {
            if viewModel.viewState.isLoading {
                ProgressView().tint(.brandPrimary)
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: .spaceMD) {
            AvatarView(url: nil, size: .xxxl, placeholder: viewModel.user?.name ?? "我")

            VStack(spacing: .spaceXS) {
                HStack(spacing: .spaceXS) {
                    Text(viewModel.user?.name ?? "用户名")
                        .font(.displaySmall)
                        .foregroundStyle(.textPrimary)

                    if let gender = viewModel.user?.gender, gender != .undisclosed {
                        Image(systemName: gender == .male ? "person.fill" : "person.fill.xmark")
                            .font(.caption)
                            .foregroundStyle(gender == .male ? .blue : .pink)
                    }
                }

                if let city = viewModel.user?.city, !city.isEmpty {
                    HStack(spacing: .spaceXXS) {
                        Image(systemName: "location")
                            .font(.captionSmall)
                        Text(city)
                            .font(.bodySmall)
                    }
                    .foregroundStyle(.textTertiary)
                }

                if let sig = viewModel.user?.signature, !sig.isEmpty {
                    Text(sig)
                        .font(.bodySmall)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spaceXXL)
                } else {
                    Text("点击编辑资料，添加个性签名")
                        .font(.bodySmall)
                        .foregroundStyle(.textTertiary)
                        .padding(.horizontal, .spaceXXL)
                }
            }
        }
        .padding(.top, .spaceXXL)
        .padding(.bottom, .spaceLG)
    }

    private var progressSection: some View {
        VStack(spacing: .spaceSM) {
            progressBar(
                label: "资料完成度",
                progress: viewModel.user?.profileCompletion ?? 0,
                color: .brandPrimary
            )
            progressBar(
                label: "认证完成度",
                progress: viewModel.user?.verificationCompletion ?? 0,
                color: .semanticSuccess
            )
        }
        .padding(.horizontal, .spaceLG)
        .padding(.bottom, .spaceMD)
    }

    private func progressBar(label: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: .spaceXS) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.bgTertiary)
                    Rectangle().fill(color)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 4)
            .clipShape(Capsule())
        }
    }

    private var verificationSection: some View {
        HStack(spacing: .spaceSM) {
            verificationBadge(
                icon: "phone.fill",
                label: "手机",
                status: viewModel.user?.phoneStatus ?? .none
            )
            verificationBadge(
                icon: "person.text.rectangle",
                label: "实名",
                status: viewModel.user?.identityStatus ?? .none
            )
            verificationBadge(
                icon: "face.smiling",
                label: "本人头像",
                status: viewModel.user?.faceStatus ?? .none
            )
        }
        .padding(.horizontal, .spaceLG)
        .padding(.bottom, .spaceLG)
    }

    private func verificationBadge(icon: String, label: String, status: User.VerificationStatus) -> some View {
        VStack(spacing: .spaceXXS) {
            ZStack {
                Circle()
                    .fill(status.isVerified ? Color.semanticSuccess.opacity(0.15) : Color.bgTertiary)
                    .frame(width: 40, height: 40)
                Image(systemName: status.isVerified ? "checkmark.circle.fill" : icon)
                    .font(.system(size: IconSize.sm.rawValue))
                    .foregroundStyle(status.isVerified ? .semanticSuccess : .textTertiary)
            }
            Text(label)
                .font(.captionSmall)
                .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: .spaceSM) {
            NavigationLink(value: AppRoute.editProfile) {
                AppButton(title: "编辑资料", variant: .outline, size: .medium, action: {})
            }
            .buttonStyle(.plain)

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

            if selectedTab == 0 {
                worksSection
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                    ForEach(1...9, id: \.self) { _ in
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

    private var worksSection: some View {
        VStack(alignment: .leading, spacing: .spaceMD) {
            let works = viewModel.user?.works ?? []
            if works.isEmpty {
                VStack(spacing: .spaceSM) {
                    Image(systemName: "music.note")
                        .font(.system(size: 32))
                        .foregroundStyle(.textTertiary)
                    Text("暂无作品")
                        .font(.bodySmall)
                        .foregroundStyle(.textTertiary)
                    Text("去编辑资料中添加你的作品吧")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.spaceXXXL)
            } else {
                ForEach(works) { work in
                    workCard(work)
                }
            }
        }
        .padding(.spaceLG)
    }

    private func workCard(_ work: User.Work) -> some View {
        HStack(spacing: .spaceMD) {
            ZStack {
                RoundedRectangle(cornerRadius: .radiusSM)
                    .fill(Color.bgTertiary)
                    .frame(width: 48, height: 48)
                Image(systemName: workIcon(work.type))
                    .font(.system(size: IconSize.md.rawValue))
                    .foregroundStyle(.brandPrimary)
            }

            VStack(alignment: .leading, spacing: .spaceXXS) {
                HStack {
                    Text(work.title)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPrimary)
                    if work.isPinned {
                        BadgeView(style: .text("置顶"))
                    }
                }
                if let summary = work.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let duration = work.duration {
                Text("\(duration)s")
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
            }
        }
        .padding(.spaceMD)
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .radiusSM))
    }

    private func workIcon(_ type: User.Work.WorkType) -> String {
        switch type {
        case .voice: return "waveform"
        case .video: return "play.circle"
        case .image: return "photo"
        }
    }
}
