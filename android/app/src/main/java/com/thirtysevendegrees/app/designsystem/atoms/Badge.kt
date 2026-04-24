package com.thirtysevendegrees.app.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.thirtysevendegrees.app.designsystem.tokens.AppColors
import com.thirtysevendegrees.app.designsystem.tokens.Spacing

sealed class BadgeStyle {
    object Dot : BadgeStyle()
    data class Count(val value: Int) : BadgeStyle()
    data class Text(val label: String) : BadgeStyle()
}

@Composable
fun Badge(style: BadgeStyle, modifier: Modifier = Modifier) {
    when (style) {
        is BadgeStyle.Dot -> {
            Box(
                modifier = modifier
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(AppColors.brandAccent)
            )
        }
        is BadgeStyle.Count -> {
            val display = if (style.value > 99) "99+" else "${style.value}"
            Box(
                modifier = modifier
                    .defaultMinSize(minWidth = 16.dp, minHeight = 16.dp)
                    .clip(CircleShape)
                    .background(AppColors.brandAccent)
                    .padding(horizontal = if (style.value > 9) 6.dp else 0.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = display,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
            }
        }
        is BadgeStyle.Text -> {
            Box(
                modifier = modifier
                    .height(20.dp)
                    .clip(RoundedCornerShape(Spacing.XS))
                    .background(AppColors.brandPrimary)
                    .padding(horizontal = Spacing.SM),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = style.label,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
            }
        }
    }
}
