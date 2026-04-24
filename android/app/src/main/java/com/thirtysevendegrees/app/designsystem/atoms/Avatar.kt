package com.thirtysevendegrees.app.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Text
import coil.compose.AsyncImage
import com.thirtysevendegrees.app.designsystem.tokens.AvatarSize
import com.thirtysevendegrees.app.designsystem.tokens.AppColors
import com.thirtysevendegrees.app.designsystem.tokens.Spacing

@Composable
fun Avatar(
    url: String?,
    size: Dp,
    placeholder: String,
    modifier: Modifier = Modifier,
    showOnlineIndicator: Boolean = false
) {
    Box(modifier = modifier) {
        Box(
            modifier = Modifier
                .size(size)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surfaceVariant),
            contentAlignment = Alignment.Center
        ) {
            if (url != null) {
                AsyncImage(
                    model = url,
                    contentDescription = null,
                    modifier = Modifier
                        .size(size)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )
            } else {
                Text(
                    text = placeholder.take(1),
                    fontSize = androidx.compose.ui.unit.TextUnit(
                        size.value * 0.4f,
                        androidx.compose.ui.unit.TextUnitType.Sp
                    ),
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        if (showOnlineIndicator) {
            Box(
                modifier = Modifier
                    .size(size * 0.25f)
                    .align(Alignment.BottomEnd)
                    .offset(x = (-2).dp, y = (-2).dp)
                    .clip(CircleShape)
                    .background(AppColors.semanticSuccess)
            )
        }
    }
}
