package com.thirtysevendegrees.app.designsystem.organisms

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun SkeletonBox(
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition()
    val shimmerOffset by infiniteTransition.animateFloat(
        initialValue = -1f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1500, easing = LinearEasing)
        )
    )
    var size by remember { mutableStateOf(IntSize.Zero) }

    Box(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .onSizeChanged { size = it }
    ) {
        if (size != IntSize.Zero) {
            val brush = Brush.linearGradient(
                colors = listOf(Color.Transparent, Color.White.copy(alpha = 0.2f), Color.Transparent),
                start = Offset(size.width * shimmerOffset, 0f),
                end = Offset(size.width * shimmerOffset + size.width, size.height.toFloat())
            )
            Box(modifier = Modifier.matchParentSize().background(brush))
        }
    }
}

@Composable
fun FeedSkeletonView(modifier: Modifier = Modifier) {
    Column(modifier = modifier) {
        repeat(3) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
                verticalAlignment = Alignment.CenterVertically
            ) {
                SkeletonBox(
                    modifier = Modifier
                        .size(AvatarSize.LG)
                        .clip(CircleShape)
                )
                Spacer(modifier = Modifier.width(Spacing.SM))
                Column(verticalArrangement = Arrangement.spacedBy(Spacing.XS)) {
                    SkeletonBox(modifier = Modifier.height(14.dp).width(120.dp).clip(CornerRadius.XS))
                    SkeletonBox(modifier = Modifier.height(10.dp).width(80.dp).clip(CornerRadius.XS))
                }
            }
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = Spacing.LG, vertical = Spacing.XS)
            ) {
                SkeletonBox(modifier = Modifier.height(14.dp).fillMaxWidth().clip(CornerRadius.XS))
                Spacer(modifier = Modifier.height(Spacing.XS))
                SkeletonBox(modifier = Modifier.height(14.dp).fillMaxWidth(0.7f).clip(CornerRadius.XS))
            }
            SkeletonBox(
                modifier = Modifier
                    .height(200.dp)
                    .fillMaxWidth()
                    .padding(horizontal = Spacing.LG, vertical = Spacing.SM)
                    .clip(CornerRadius.MD)
            )
        }
    }
}
