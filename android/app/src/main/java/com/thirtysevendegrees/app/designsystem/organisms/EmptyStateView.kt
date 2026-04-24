package com.thirtysevendegrees.app.designsystem.organisms

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Inbox
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.AppButton
import com.thirtysevendegrees.app.designsystem.atoms.ButtonSize
import com.thirtysevendegrees.app.designsystem.atoms.ButtonVariant
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun EmptyStateView(
    title: String,
    subtitle: String,
    actionTitle: String? = null,
    onAction: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = Spacing.XXL),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(Spacing.XXXL))
        Icon(
            imageVector = Icons.Default.Inbox,
            contentDescription = null,
            modifier = Modifier.size(IconSize.XXL),
            tint = AppColors.textTertiaryLight
        )
        Spacer(modifier = Modifier.height(Spacing.MD))
        Text(title, style = MaterialTheme.typography.headlineMedium, color = AppColors.textSecondaryLight)
        Spacer(modifier = Modifier.height(Spacing.XS))
        Text(subtitle, style = MaterialTheme.typography.bodySmall, color = AppColors.textTertiaryLight)
        if (actionTitle != null && onAction != null) {
            Spacer(modifier = Modifier.height(Spacing.LG))
            AppButton(
                text = actionTitle,
                onClick = onAction,
                variant = ButtonVariant.Secondary,
                size = ButtonSize.Medium,
                modifier = Modifier.width(120.dp)
            )
        }
    }
}
