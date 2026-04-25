import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTabBar.AppTab = .feed
    @State private var feedPath = NavigationPath()
    @State private var chatPath = NavigationPath()
    @State private var discoverPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    @State private var showCreation = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                NavigationStack(path: $feedPath) {
                    FeedView()
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(route)
                        }
                }
                .opacity(selectedTab == .feed ? 1 : 0)

                NavigationStack(path: $chatPath) {
                    ChatListView()
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(route)
                        }
                }
                .opacity(selectedTab == .chat ? 1 : 0)

                NavigationStack(path: $discoverPath) {
                    DiscoverView()
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(route)
                        }
                }
                .opacity(selectedTab == .discover ? 1 : 0)

                NavigationStack(path: $profilePath) {
                    ProfileView()
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(route)
                        }
                }
                .opacity(selectedTab == .profile ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AppTabBar(selectedTab: $selectedTab, messageBadge: 3)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .publish {
                selectedTab = .feed
                showCreation = true
            }
        }
        .fullScreenCover(isPresented: $showCreation) {
            CreationView()
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .postDetail(let id):
            Text("帖子详情: \(id)")
        case .userProfile(let id):
            Text("用户主页: \(id)")
        case .topic(let tag):
            Text("话题: \(tag)")
        case .chatConversation(let id):
            ChatDetailView(conversationId: id, username: "用户")
        case .search:
            Text("搜索")
        case .settings:
            NotificationsView()
        case .editProfile:
            Text("编辑资料")
        }
    }
}
