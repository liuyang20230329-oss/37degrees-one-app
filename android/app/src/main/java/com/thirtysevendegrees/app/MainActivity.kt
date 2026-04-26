package com.thirtysevendegrees.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.thirtysevendegrees.app.designsystem.organisms.AppTab
import com.thirtysevendegrees.app.designsystem.organisms.AppTabBar
import com.thirtysevendegrees.app.designsystem.tokens.AppTypography
import com.thirtysevendegrees.app.features.auth.ui.AuthScreen
import com.thirtysevendegrees.app.navigation.MainNavHost
import com.thirtysevendegrees.app.navigation.Screen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MaterialTheme(
                typography = AppTypography
            ) {
                var isLoggedIn by remember { mutableStateOf(false) }

                if (!isLoggedIn) {
                    AuthScreen(onLoginSuccess = { isLoggedIn = true })
                } else {
                    val navController = rememberNavController()
                    val navBackStackEntry by navController.currentBackStackEntryAsState()
                    val currentRoute = navBackStackEntry?.destination?.route
                    val selectedTab = when (currentRoute) {
                        Screen.ChatList.route, Screen.ChatConversation.route -> AppTab.Chat
                        Screen.Discover.route, Screen.Search.route -> AppTab.Discover
                        Screen.Profile.route, Screen.EditProfile.route, Screen.Settings.route -> AppTab.Profile
                        else -> AppTab.Feed
                    }

                    Column(modifier = Modifier.fillMaxSize()) {
                        Box(modifier = Modifier.weight(1f)) {
                            MainNavHost(navController)
                        }
                        AppTabBar(
                            selectedTab = selectedTab,
                            onTabSelected = { tab ->
                                if (tab == AppTab.Publish) return@AppTabBar
                                val route = when (tab) {
                                    AppTab.Feed -> Screen.Feed.route
                                    AppTab.Chat -> Screen.ChatList.route
                                    AppTab.Discover -> Screen.Discover.route
                                    AppTab.Profile -> Screen.Profile.route
                                    AppTab.Publish -> return@AppTabBar
                                }
                                navController.navigate(route) {
                                    popUpTo(Screen.Feed.route) { inclusive = false }
                                    launchSingleTop = true
                                }
                            },
                            messageBadge = 3
                        )
                    }
                }
            }
        }
    }
}
