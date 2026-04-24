package com.thirtysevendegrees.app.designsystem.atoms

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.*

enum class ButtonVariant { Primary, Secondary, Outline, Ghost, Danger }
enum class ButtonSize { Large, Medium, Small }

@Composable
fun AppButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.Primary,
    size: ButtonSize = ButtonSize.Large,
    isLoading: Boolean = false
) {
    val height = when (size) {
        ButtonSize.Large -> 48.dp
        ButtonSize.Medium -> 40.dp
        ButtonSize.Small -> 32.dp
    }
    val cornerShape = when (size) {
        ButtonSize.Small -> CornerRadius.XS
        else -> CornerRadius.MD
    }
    val textStyle = when (size) {
        ButtonSize.Small -> MaterialTheme.typography.labelMedium
        else -> MaterialTheme.typography.labelLarge
    }

    val containerColor = when (variant) {
        ButtonVariant.Primary -> AppColors.brandPrimary
        ButtonVariant.Secondary -> AppColors.brandPrimaryLight
        ButtonVariant.Danger -> AppColors.semanticError
        ButtonVariant.Outline, ButtonVariant.Ghost -> Color.Transparent
    }
    val contentColor = when (variant) {
        ButtonVariant.Primary, ButtonVariant.Danger -> Color.White
        ButtonVariant.Secondary, ButtonVariant.Outline, ButtonVariant.Ghost -> AppColors.brandPrimary
    }

    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(height),
        enabled = !isLoading,
        shape = cornerShape,
        colors = ButtonDefaults.outlinedButtonColors(
            containerColor = containerColor,
            contentColor = contentColor,
            disabledContainerColor = containerColor.copy(alpha = 0.4f),
            disabledContentColor = contentColor.copy(alpha = 0.4f)
        ),
        border = if (variant == ButtonVariant.Outline)
            BorderStroke(1.dp, AppColors.brandPrimary) else null
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(16.dp),
                strokeWidth = 2.dp,
                color = if (variant == ButtonVariant.Primary || variant == ButtonVariant.Danger)
                    Color.White else AppColors.brandPrimary
            )
            Spacer(modifier = Modifier.width(Spacing.XS))
        }
        Text(text = text, style = textStyle)
    }
}
