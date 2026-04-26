package com.thirtysevendegrees.app.designsystem.molecules

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun PostCard(
    avatarUrl: String?,
    username: String,
    handle: String,
    timeAgo: String,
    content: String,
    tags: List<String>,
    imageUrls: List<String>,
    likeCount: Int,
    commentCount: Int,
    isLiked: Boolean,
    onLike: () -> Unit,
    onComment: () -> Unit,
    onShare: () -> Unit,
    onMore: () -> Unit,
    onAvatarTap: () -> Unit,
    onTagTap: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.background(AppColors.bgPrimaryLight)) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Avatar(
                url = avatarUrl, size = AvatarSize.LG, placeholder = username,
                modifier = Modifier.clickable(onClick = onAvatarTap)
            )
            Spacer(modifier = Modifier.width(Spacing.SM))
            Column {
                Text(username, style = MaterialTheme.typography.headlineMedium, maxLines = 1)
                Row(horizontalArrangement = Arrangement.spacedBy(Spacing.XS)) {
                    Text("@$handle", style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
                    Text("·", color = AppColors.textTertiaryLight)
                    Text(timeAgo, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
                }
            }
        }

        if (content.isNotEmpty()) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = Spacing.LG)
                    .padding(bottom = Spacing.SM)
            ) {
                Text(
                    content,
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 6,
                    overflow = TextOverflow.Ellipsis,
                    color = AppColors.textPrimaryLight
                )
                if (tags.isNotEmpty()) {
                    Row(horizontalArrangement = Arrangement.spacedBy(Spacing.XS)) {
                        tags.forEach { tag ->
                            Text(
                                "#$tag",
                                style = MaterialTheme.typography.labelSmall,
                                color = AppColors.brandPrimary,
                                modifier = Modifier.clickable { onTagTap(tag) }
                            )
                        }
                    }
                }
            }
        }

        if (imageUrls.isNotEmpty()) {
            MediaGrid(
                imageUrls = imageUrls,
                modifier = Modifier.padding(horizontal = Spacing.LG, vertical = Spacing.SM)
            )
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
                .padding(horizontal = Spacing.LG),
            verticalAlignment = Alignment.CenterVertically
        ) {
            ActionButton(
                icon = if (isLiked) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                count = likeCount,
                tint = if (isLiked) AppColors.brandPrimary else AppColors.textTertiaryLight,
                onClick = onLike
            )
            ActionButton(icon = Icons.Default.ChatBubbleOutline, count = commentCount, tint = AppColors.textTertiaryLight, onClick = onComment)
            ActionButton(icon = Icons.Default.Share, count = null, tint = AppColors.textTertiaryLight, onClick = onShare)
            Spacer(modifier = Modifier.weight(1f))
            IconButton(onClick = onMore, modifier = Modifier.size(44.dp)) {
                Icon(Icons.Default.MoreHoriz, contentDescription = null, tint = AppColors.textTertiaryLight)
            }
        }
    }
}

@Composable
private fun ActionButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    count: Int?,
    tint: Color,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .height(44.dp)
            .clickable(onClick = onClick)
            .padding(horizontal = Spacing.SM),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(IconSize.MD))
        if (count != null) {
            Spacer(modifier = Modifier.width(Spacing.XXS))
            Text("$count", style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
        }
    }
}

@Composable
fun MediaGrid(imageUrls: List<String>, modifier: Modifier = Modifier) {
    val columns = when (imageUrls.size) {
        1 -> 1
        2 -> 2
        else -> 3
    }
    LazyVerticalGrid(
        columns = GridCells.Fixed(columns),
        horizontalArrangement = Arrangement.spacedBy(2.dp),
        verticalArrangement = Arrangement.spacedBy(2.dp),
        modifier = modifier.heightIn(max = 300.dp),
        userScrollEnabled = false
    ) {
        items(imageUrls) { url ->
            AsyncImage(
                model = url,
                contentDescription = null,
                modifier = Modifier
                    .aspectRatio(1f)
                    .clip(CornerRadius.MD),
                contentScale = ContentScale.Crop
            )
        }
    }
}
