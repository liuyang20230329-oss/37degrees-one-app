import SwiftUI

enum AppRoute: Hashable {
    case postDetail(String)
    case userProfile(String)
    case topic(String)
    case chatConversation(String)
    case search
    case settings
    case editProfile
    case notifications
    case creation
}

typealias FeedRoute = AppRoute
typealias ChatRoute = AppRoute
typealias DiscoverRoute = AppRoute
typealias ProfileRoute = AppRoute
