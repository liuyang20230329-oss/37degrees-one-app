package com.thirtysevendegrees.app.designsystem.molecules

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun StoryItem(
    avatarUrl: String?,
    username: String,
    isViewed: Boolean,
    isMine: Boolean,
    onTap: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .width(76.dp)
            .clickable(onClick = onTap),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(contentAlignment = Alignment.TopStart) {
            Box(
                modifier = Modifier
                    .size(76.dp)
                    .clip(CircleShape)
                    .background(if (isViewed) AppColors.dividerLight else AppColors.brandPrimary)
                    .padding(2.5.dp)
                    .clip(CircleShape)
                    .background(AppColors.bgPrimaryLight)
                    .padding(2.5.dp)
            ) {
                Avatar(
                    url = avatarUrl,
                    size = AvatarSize.LG,
                    placeholder = username
                )
            }
            if (isMine) {
                Icon(
                    imageVector = Icons.Default.AddCircle,
                    contentDescription = null,
                    tint = AppColors.brandPrimary,
                    modifier = Modifier
                        .size(16.dp)
                        .align(Alignment.BottomEnd)
                        .offset(x = 4.dp, y = 4.dp)
                )
            }
        }
        Spacer(modifier = Modifier.height(Spacing.XS))
        Text(
            text = username,
            style = MaterialTheme.typography.labelSmall,
            color = AppColors.textPrimaryLight,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}
