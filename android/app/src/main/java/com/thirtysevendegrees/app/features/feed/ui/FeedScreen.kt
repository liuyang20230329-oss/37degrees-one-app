package com.thirtysevendegrees.app.features.feed.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.molecules.PostCard
import com.thirtysevendegrees.app.designsystem.molecules.StoryItem
import com.thirtysevendegrees.app.designsystem.tokens.*

data class FeedPost(
    val id: String,
    val username: String,
    val avatarUrl: String?,
    val content: String,
    val tags: List<String>,
    val imageUrls: List<String>,
    val likeCount: Int,
    val commentCount: Int,
    val isLiked: Boolean,
    val timeAgo: String
)

@Composable
fun FeedScreen(
    onPostClick: (String) -> Unit,
    onUserClick: (String) -> Unit,
    onTopicClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedSegment by remember { mutableIntStateOf(0) }
    val samplePosts = remember {
        (1..10).map { i ->
            FeedPost(
                id = "$i",
                username = "用户$i",
                avatarUrl = null,
                content = "这是第$i条动态内容，分享生活中的美好瞬间",
                tags = listOf("日常", "分享"),
                imageUrls = emptyList(),
                likeCount = i * 12,
                commentCount = i * 3,
                isLiked = i % 3 == 0,
                timeAgo = "${i}分钟前"
            )
        }
    }

    Column(modifier = modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            horizontalArrangement = Arrangement.Center
        ) {
            Text("首页", style = MaterialTheme.typography.headlineMedium)
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            listOf("推荐", "关注").forEachIndexed { index, title ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .weight(1f)
                        .clickable { selectedSegment = index }
                        .padding(vertical = Spacing.XS)
                ) {
                    Text(
                        title,
                        style = if (selectedSegment == index) MaterialTheme.typography.headlineMedium
                        else MaterialTheme.typography.bodyMedium,
                        fontWeight = if (selectedSegment == index) FontWeight.SemiBold else FontWeight.Normal,
                        color = if (selectedSegment == index) AppColors.textPrimaryLight else AppColors.textTertiaryLight
                    )
                    Spacer(modifier = Modifier.height(Spacing.XS))
                    Box(
                        modifier = Modifier
                            .height(2.dp)
                            .fillMaxWidth(0.5f)
                            .background(if (selectedSegment == index) AppColors.brandPrimary else androidx.compose.ui.graphics.Color.Transparent)
                    )
                }
            }
        }

        LazyRow(
            contentPadding = PaddingValues(horizontal = Spacing.LG),
            horizontalArrangement = Arrangement.spacedBy(Spacing.SM),
            modifier = Modifier.padding(vertical = Spacing.SM)
        ) {
            item {
                StoryItem(avatarUrl = null, username = "我的", isViewed = false, isMine = true, onTap = {})
            }
            items((1..8).toList()) { i ->
                StoryItem(avatarUrl = null, username = "用户$i", isViewed = i > 4, isMine = false, onTap = {})
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            items(samplePosts) { post ->
                PostCard(
                    avatarUrl = post.avatarUrl,
                    username = post.username,
                    handle = "user${post.id}",
                    timeAgo = post.timeAgo,
                    content = post.content,
                    tags = post.tags,
                    imageUrls = post.imageUrls,
                    likeCount = post.likeCount,
                    commentCount = post.commentCount,
                    isLiked = post.isLiked,
                    onLike = {},
                    onComment = { onPostClick(post.id) },
                    onShare = {},
                    onMore = {},
                    onAvatarTap = { onUserClick(post.id) },
                    onTagTap = onTopicClick
                )
                HorizontalDivider(color = AppColors.dividerLight, thickness = 0.5.dp)
            }
        }
    }
}
