package com.thirtysevendegrees.app.designsystem.organisms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.tokens.*

data class CommentItem(
    val id: String,
    val username: String,
    val avatarUrl: String?,
    val content: String,
    val timeAgo: String,
    val likeCount: Int
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CommentSheet(
    commentCount: Int,
    comments: List<CommentItem>,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier
) {
    var commentText by remember { mutableStateOf("") }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp))
            .background(AppColors.bgPrimaryLight)
    ) {
        Box(
            modifier = Modifier
                .padding(top = Spacing.SM, bottom = Spacing.XS)
                .align(Alignment.CenterHorizontally)
                .size(width = 36.dp, height = 4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(AppColors.dividerLight)
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
                .padding(horizontal = Spacing.LG),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("评论 $commentCount", style = MaterialTheme.typography.headlineMedium)
            Spacer(modifier = Modifier.weight(1f))
            IconButton(onClick = onDismiss) {
                Icon(Icons.Default.Close, contentDescription = "关闭")
            }
        }

        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = Spacing.LG),
            verticalArrangement = Arrangement.spacedBy(Spacing.MD)
        ) {
            items(comments) { comment ->
                CommentRow(comment)
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(AppColors.bgPrimaryLight)
                .padding(horizontal = Spacing.LG),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Avatar(url = null, size = AvatarSize.SM, placeholder = "我")
            Spacer(modifier = Modifier.width(Spacing.SM))
            OutlinedTextField(
                value = commentText,
                onValueChange = { commentText = it },
                placeholder = { Text("说点什么...") },
                modifier = Modifier.weight(1f),
                shape = CornerRadius.MD,
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = AppColors.bgTertiaryLight,
                    focusedContainerColor = AppColors.bgTertiaryLight
                )
            )
            IconButton(onClick = { }) { Icon(Icons.Default.EmojiEmotions, contentDescription = null) }
            IconButton(onClick = { }) { Icon(Icons.Default.Image, contentDescription = null) }
        }
    }
}

@Composable
private fun CommentRow(comment: CommentItem) {
    Row(modifier = Modifier.fillMaxWidth()) {
        Avatar(url = comment.avatarUrl, size = AvatarSize.SM, placeholder = comment.username)
        Spacer(modifier = Modifier.width(Spacing.SM))
        Column(modifier = Modifier.weight(1f)) {
            Text(comment.username, style = MaterialTheme.typography.labelSmall, color = AppColors.textSecondaryLight)
            Text(comment.content, style = MaterialTheme.typography.bodySmall, color = AppColors.textPrimaryLight)
            Row(horizontalArrangement = Arrangement.spacedBy(Spacing.MD)) {
                Text(comment.timeAgo, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
                Text("回复", style = MaterialTheme.typography.labelSmall, color = AppColors.textSecondaryLight)
            }
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(Icons.Default.FavoriteBorder, contentDescription = null, tint = AppColors.textTertiaryLight, modifier = Modifier.size(IconSize.SM))
            Text("${comment.likeCount}", style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
        }
    }
}
