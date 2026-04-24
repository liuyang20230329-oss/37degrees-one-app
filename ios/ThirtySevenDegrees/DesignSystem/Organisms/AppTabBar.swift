import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    var messageBadge: Int = 0

    enum AppTab: CaseIterable {
        case feed, chat, publish, discover, profile

        var title: String {
            switch self {
            case .feed: return "首页"
            case .chat: return "消息"
            case .publish: return "发布"
            case .discover: return "发现"
            case .profile: return "我的"
            }
        }

        var icon: String {
            switch self {
            case .feed: return "house.fill"
            case .chat: return "message.fill"
            case .publish: return "plus.circle.fill"
            case .discover: return "magnifyingglass"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .background(Color.bgPrimary)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.dividerColor)
                .frame(height: 0.5)
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(.appFast) { selectedTab = tab }
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: tab == .publish ? 32 : IconSize.md.rawValue))
                        .foregroundStyle(tab == selectedTab ? Color.brandPrimary : Color.textTertiary)
                        .scaleEffect(tab == selectedTab ? 1.0 : 0.9)

                    if tab == .chat && messageBadge > 0 {
                        BadgeView(style: .count(messageBadge))
                            .offset(x: 8, y: -4)
                    }
                }
                Text(tab.title)
                    .font(.captionSmall)
                    .foregroundStyle(tab == selectedTab ? Color.brandPrimary : Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, .spaceSM)
            .padding(.bottom, 4)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AppTabBar(selectedTab: .constant(.feed), messageBadge: 5)
    }
}
