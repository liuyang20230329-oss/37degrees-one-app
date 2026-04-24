package com.thirtysevendegrees.app.navigation

sealed class Screen(val route: String) {
    object Feed : Screen("feed")
    object PostDetail : Screen("post/{postId}") {
        fun createRoute(postId: String) = "post/$postId"
    }
    object UserProfile : Screen("user/{userId}") {
        fun createRoute(userId: String) = "user/$userId"
    }
    object Topic : Screen("topic/{tag}") {
        fun createRoute(tag: String) = "topic/$tag"
    }
    object ChatList : Screen("chat_list")
    object ChatConversation : Screen("chat/{conversationId}") {
        fun createRoute(conversationId: String) = "chat/$conversationId"
    }
    object Discover : Screen("discover")
    object Search : Screen("search")
    object Profile : Screen("profile")
    object Settings : Screen("settings")
    object EditProfile : Screen("edit_profile")
    object Auth : Screen("auth")
}
