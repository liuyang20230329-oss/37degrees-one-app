package com.thirtysevendegrees.app.features.notifications.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.organisms.AppNavigationBar
import com.thirtysevendegrees.app.designsystem.tokens.*

enum class NotificationType { Like, Comment, Follow, Mention, System }

data class NotificationItem(
    val id: String,
    val type: NotificationType,
    val username: String,
    val avatarUrl: String?,
    val content: String,
    val timeAgo: String,
    val isRead: Boolean
)

@Composable
fun NotificationsScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val notifications = listOf(
        NotificationItem("1", NotificationType.Like, "用户A", null, "赞了你的动态", "3分钟前", false),
        NotificationItem("2", NotificationType.Comment, "用户B", null, "评论了你的动态：太棒了！", "10分钟前", false),
        NotificationItem("3", NotificationType.Follow, "用户C", null, "关注了你", "1小时前", true),
        NotificationItem("4", NotificationType.Mention, "用户D", null, "在评论中提到了你", "2小时前", true),
        NotificationItem("5", NotificationType.System, "系统", null, "你的动态已通过审核", "1天前", true)
    )

    Column(modifier = modifier.fillMaxSize()) {
        AppNavigationBar(title = "通知", onBack = onBack)

        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(notifications) { item ->
                NotificationRow(item)
            }
        }
    }
}

@Composable
private fun NotificationRow(item: NotificationItem) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(if (item.isRead) AppColors.bgPrimaryLight else AppColors.brandPrimaryLight)
            .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Avatar(url = item.avatarUrl, size = AvatarSize.MD, placeholder = item.username)
        Spacer(modifier = Modifier.width(Spacing.SM))
        Column(modifier = Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(item.username, style = MaterialTheme.typography.bodyMedium, color = AppColors.textPrimaryLight, modifier = Modifier.weight(1f))
                Text(item.timeAgo, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
            }
            Text(item.content, style = MaterialTheme.typography.bodySmall, color = AppColors.textSecondaryLight, maxLines = 2)
        }
        Spacer(modifier = Modifier.width(Spacing.SM))
        NotificationIcon(item.type)
    }
}

@Composable
private fun NotificationIcon(type: NotificationType) {
    val (icon, color) = when (type) {
        NotificationType.Like -> Icons.Default.Favorite to AppColors.brandPrimary
        NotificationType.Comment -> Icons.Default.ChatBubble to AppColors.brandSecondary
        NotificationType.Follow -> Icons.Default.PersonAdd to AppColors.brandPrimary
        NotificationType.Mention -> Icons.Default.AlternateEmail to AppColors.semanticInfo
        NotificationType.System -> Icons.Default.Notifications to AppColors.semanticWarning
    }
    Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(IconSize.MD))
}
