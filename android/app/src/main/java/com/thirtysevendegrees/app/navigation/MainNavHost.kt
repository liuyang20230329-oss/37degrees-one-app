package com.thirtysevendegrees.app.navigation

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.thirtysevendegrees.app.features.feed.ui.FeedScreen
import com.thirtysevendegrees.app.features.chat.ui.ChatListScreen
import com.thirtysevendegrees.app.features.discover.ui.DiscoverScreen
import com.thirtysevendegrees.app.features.profile.ui.ProfileScreen

@Composable
fun MainNavHost(
    navController: NavHostController,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Feed.route,
        modifier = modifier
    ) {
        composable(Screen.Feed.route) {
            FeedScreen(
                onPostClick = { postId -> navController.navigate(Screen.PostDetail.createRoute(postId)) },
                onUserClick = { userId -> navController.navigate(Screen.UserProfile.createRoute(userId)) },
                onTopicClick = { tag -> navController.navigate(Screen.Topic.createRoute(tag)) }
            )
        }
        composable(
            Screen.PostDetail.route,
            arguments = listOf(navArgument("postId") { type = NavType.StringType })
        ) { backStackEntry ->
            val postId = backStackEntry.arguments?.getString("postId") ?: ""
            PostDetailPlaceholder(postId)
        }
        composable(
            Screen.UserProfile.route,
            arguments = listOf(navArgument("userId") { type = NavType.StringType })
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getString("userId") ?: ""
            UserProfilePlaceholder(userId)
        }
        composable(
            Screen.Topic.route,
            arguments = listOf(navArgument("tag") { type = NavType.StringType })
        ) { backStackEntry ->
            val tag = backStackEntry.arguments?.getString("tag") ?: ""
            TopicPlaceholder(tag)
        }

        composable(Screen.ChatList.route) {
            ChatListScreen(
                onConversationClick = { convId -> navController.navigate(Screen.ChatConversation.createRoute(convId)) }
            )
        }
        composable(
            Screen.ChatConversation.route,
            arguments = listOf(navArgument("conversationId") { type = NavType.StringType })
        ) { backStackEntry ->
            val convId = backStackEntry.arguments?.getString("conversationId") ?: ""
            ChatPlaceholder(convId)
        }

        composable(Screen.Discover.route) {
            DiscoverScreen(
                onSearchClick = { navController.navigate(Screen.Search.route) }
            )
        }

        composable(Screen.Search.route) {
            SearchPlaceholder()
        }

        composable(Screen.Profile.route) {
            ProfileScreen(
                onSettingsClick = { navController.navigate(Screen.Settings.route) },
                onEditProfileClick = { navController.navigate(Screen.EditProfile.route) }
            )
        }

        composable(Screen.Settings.route) { SettingsPlaceholder() }
        composable(Screen.EditProfile.route) { EditProfilePlaceholder() }
    }
}

@Composable
private fun PostDetailPlaceholder(postId: String) {
    androidx.compose.material3.Text("帖子详情: $postId")
}

@Composable
private fun UserProfilePlaceholder(userId: String) {
    androidx.compose.material3.Text("用户主页: $userId")
}

@Composable
private fun TopicPlaceholder(tag: String) {
    androidx.compose.material3.Text("话题: $tag")
}

@Composable
private fun ChatPlaceholder(convId: String) {
    androidx.compose.material3.Text("聊天: $convId")
}

@Composable
private fun SettingsPlaceholder() {
    androidx.compose.material3.Text("设置")
}

@Composable
private fun EditProfilePlaceholder() {
    androidx.compose.material3.Text("编辑资料")
}

@Composable
private fun SearchPlaceholder() {
    androidx.compose.material3.Text("搜索")
}
