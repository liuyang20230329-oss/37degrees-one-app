package com.thirtysevendegrees.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.thirtysevendegrees.app.designsystem.organisms.AppTab
import com.thirtysevendegrees.app.designsystem.organisms.AppTabBar
import com.thirtysevendegrees.app.features.auth.ui.AuthScreen
import com.thirtysevendegrees.app.navigation.MainNavHost

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            var isLoggedIn by remember { mutableStateOf(false) }
            var selectedTab by remember { mutableStateOf(AppTab.Feed) }

            if (!isLoggedIn) {
                AuthScreen(onLoginSuccess = { isLoggedIn = true })
            } else {
                val navController = rememberNavController()
                Column(modifier = Modifier.fillMaxSize()) {
                    Box(modifier = Modifier.weight(1f)) {
                        when (selectedTab) {
                            AppTab.Feed -> MainNavHost(navController, selectedTab)
                            AppTab.Chat -> MainNavHost(navController, selectedTab)
                            AppTab.Publish -> { /* Modal handled externally */ }
                            AppTab.Discover -> MainNavHost(navController, selectedTab)
                            AppTab.Profile -> MainNavHost(navController, selectedTab)
                        }
                    }
                    AppTabBar(
                        selectedTab = selectedTab,
                        onTabSelected = { tab ->
                            if (tab == AppTab.Publish) return@AppTabBar
                            selectedTab = tab
                        },
                        messageBadge = 3
                    )
                }
            }
        }
    }
}
