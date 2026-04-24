package com.thirtysevendegrees.app.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun Tag(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .height(28.dp)
            .clip(RoundedCornerShape(Spacing.XS))
            .background(if (isSelected) AppColors.brandPrimary else AppColors.bgTertiaryLight)
            .clickable(onClick = onClick)
            .padding(horizontal = Spacing.MD),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelMedium,
            color = if (isSelected) Color.White else AppColors.textSecondaryLight
        )
    }
}
