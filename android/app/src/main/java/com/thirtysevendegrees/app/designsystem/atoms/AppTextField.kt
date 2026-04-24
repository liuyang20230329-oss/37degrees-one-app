package com.thirtysevendegrees.app.designsystem.atoms

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun AppTextField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    errorMessage: String? = null,
    maxLength: Int? = null,
    isSecure: Boolean = false
) {
    val isError = errorMessage != null
    val borderColor = when {
        isError -> AppColors.semanticError
        value.isNotEmpty() -> AppColors.brandPrimary
        else -> AppColors.borderLight
    }

    Column(modifier = modifier) {
        OutlinedTextField(
            value = value,
            onValueChange = { newText ->
                if (maxLength == null || newText.length <= maxLength) {
                    onValueChange(newText)
                }
            },
            placeholder = { Text(placeholder, style = MaterialTheme.typography.bodySmall) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(Spacing.SM),
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = AppColors.bgTertiaryLight,
                unfocusedContainerColor = AppColors.bgTertiaryLight,
                focusedBorderColor = borderColor,
                unfocusedBorderColor = if (value.isEmpty()) Color.Transparent else borderColor,
                errorBorderColor = AppColors.semanticError,
                cursorColor = AppColors.brandPrimary
            ),
            textStyle = MaterialTheme.typography.bodyMedium.copy(
                color = AppColors.textPrimaryLight
            ),
            singleLine = true,
            isError = isError
        )

        Row(
            modifier = Modifier.fillMaxWidth().padding(top = Spacing.XS),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            if (errorMessage != null) {
                Text(
                    text = errorMessage,
                    style = MaterialTheme.typography.labelSmall,
                    color = AppColors.semanticError
                )
            }
            if (maxLength != null) {
                Text(
                    text = "${value.length}/$maxLength",
                    style = MaterialTheme.typography.labelSmall,
                    color = AppColors.textTertiaryLight
                )
            }
        }
    }
}
