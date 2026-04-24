package com.thirtysevendegrees.app.designsystem.molecules

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun ChatBubble(
    message: String,
    isOwn: Boolean,
    time: String,
    showAvatar: Boolean = true,
    avatarUrl: String? = null,
    senderName: String = "",
    modifier: Modifier = Modifier
) {
    val maxWidth = LocalConfiguration.current.screenWidthDp.dp * 0.7f
    val bubbleShape = if (isOwn) {
        RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp, bottomStart = 12.dp, bottomEnd = 4.dp)
    } else {
        RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp, bottomStart = 4.dp, bottomEnd = 12.dp)
    }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = Spacing.LG),
        verticalAlignment = Alignment.Bottom
    ) {
        if (!isOwn && showAvatar) {
            Avatar(url = avatarUrl, size = AvatarSize.XS, placeholder = senderName)
            Spacer(modifier = Modifier.width(Spacing.SM))
        }

        Column(
            horizontalAlignment = if (isOwn) Alignment.End else Alignment.Start
        ) {
            Box(
                modifier = Modifier
                    .widthIn(max = maxWidth)
                    .clip(bubbleShape)
                    .background(if (isOwn) AppColors.brandPrimary else AppColors.bgTertiaryLight)
                    .padding(horizontal = Spacing.MD, vertical = Spacing.SM)
            ) {
                Text(
                    text = message,
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (isOwn) androidx.compose.ui.graphics.Color.White else AppColors.textPrimaryLight
                )
            }
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = time,
                style = MaterialTheme.typography.labelSmall,
                color = AppColors.textTertiaryLight
            )
        }

        if (isOwn) {
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
