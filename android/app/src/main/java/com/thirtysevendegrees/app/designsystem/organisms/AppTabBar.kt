package com.thirtysevendegrees.app.designsystem.organisms

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Badge
import com.thirtysevendegrees.app.designsystem.atoms.BadgeStyle
import com.thirtysevendegrees.app.designsystem.tokens.*

enum class AppTab(
    val title: String,
    val icon: ImageVector,
    val iconSize: Dp = IconSize.MD
) {
    Feed("首页", Icons.Default.Home),
    Chat("消息", Icons.Default.Chat),
    Publish("发布", Icons.Default.AddCircle, IconSize.XL),
    Discover("发现", Icons.Default.Search),
    Profile("我的", Icons.Default.Person)
}

@Composable
fun AppTabBar(
    selectedTab: AppTab,
    onTabSelected: (AppTab) -> Unit,
    messageBadge: Int = 0,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColors.bgPrimaryLight),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        AppTab.entries.forEach { tab ->
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clickable { onTabSelected(tab) }
                    .padding(top = Spacing.SM, bottom = 4.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                val selected = tab == selectedTab
                val scale by animateFloatAsState(
                    targetValue = if (selected) 1f else 0.9f,
                    animationSpec = AppAnimationSpec.fast(),
                    label = "tabScale"
                )

                Box {
                    Icon(
                        imageVector = tab.icon,
                        contentDescription = tab.title,
                        tint = if (selected) AppColors.brandPrimary else AppColors.textTertiaryLight,
                        modifier = Modifier
                            .size(tab.iconSize)
                            .scale(scale)
                    )
                    if (tab == AppTab.Chat && messageBadge > 0) {
                        Badge(
                            style = BadgeStyle.Count(messageBadge),
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .offset(x = 8.dp, y = (-4).dp)
                        )
                    }
                }
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = tab.title,
                    style = MaterialTheme.typography.labelSmall,
                    color = if (selected) AppColors.brandPrimary else AppColors.textTertiaryLight,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}
