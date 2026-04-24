package com.thirtysevendegrees.app.features.chat.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.atoms.Badge
import com.thirtysevendegrees.app.designsystem.atoms.BadgeStyle
import com.thirtysevendegrees.app.designsystem.molecules.SearchBar
import com.thirtysevendegrees.app.designsystem.tokens.*

data class ConversationItem(
    val id: String,
    val username: String,
    val avatarUrl: String?,
    val lastMessage: String,
    val timeAgo: String,
    val unreadCount: Int,
    val isPinned: Boolean
)

@Composable
fun ChatListScreen(
    onConversationClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val conversations = (1..10).map { i ->
        ConversationItem(
            id = "$i",
            username = if (i == 1) "37度小助手" else "用户$i",
            avatarUrl = null,
            lastMessage = "这是最后一条消息的预览内容...",
            timeAgo = "${i}分钟前",
            unreadCount = if (i <= 3) i else 0,
            isPinned = i == 1
        )
    }

    Column(modifier = modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("消息", style = MaterialTheme.typography.headlineMedium, modifier = Modifier.weight(1f))
        }

        SearchBar(placeholder = "搜索", onTap = { }, modifier = Modifier.padding(horizontal = Spacing.LG, vertical = Spacing.SM))

        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(conversations) { convo ->
                ConversationRow(
                    conversation = convo,
                    onClick = { onConversationClick(convo.id) }
                )
                HorizontalDivider(color = AppColors.dividerLight, thickness = 0.5.dp)
            }
        }
    }
}

@Composable
private fun ConversationRow(conversation: ConversationItem, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .background(if (conversation.isPinned) AppColors.bgSecondaryLight else AppColors.bgPrimaryLight)
            .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Avatar(url = conversation.avatarUrl, size = AvatarSize.LG, placeholder = conversation.username)
        Spacer(modifier = Modifier.width(Spacing.SM))
        Column(modifier = Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    conversation.username,
                    style = MaterialTheme.typography.bodyMedium,
                    color = AppColors.textPrimaryLight,
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(conversation.timeAgo, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
            }
            Spacer(modifier = Modifier.height(Spacing.XXS))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    conversation.lastMessage,
                    style = MaterialTheme.typography.bodySmall,
                    color = AppColors.textTertiaryLight,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
                if (conversation.unreadCount > 0) {
                    Spacer(modifier = Modifier.width(Spacing.XS))
                    Badge(style = BadgeStyle.Count(conversation.unreadCount))
                }
            }
        }
    }
}
