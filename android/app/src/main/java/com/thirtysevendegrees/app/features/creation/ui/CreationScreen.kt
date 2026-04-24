package com.thirtysevendegrees.app.features.creation.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.AppButton
import com.thirtysevendegrees.app.designsystem.atoms.ButtonSize
import com.thirtysevendegrees.app.designsystem.atoms.ButtonVariant
import com.thirtysevendegrees.app.designsystem.organisms.AppNavigationBar
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun CreationScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier
) {
    var text by remember { mutableStateOf("") }

    Column(modifier = modifier.fillMaxSize()) {
        AppNavigationBar(
            title = "发布动态",
            onBack = onDismiss,
            rightActions = listOf()
        )

        OutlinedTextField(
            value = text,
            onValueChange = { text = it },
            placeholder = { Text("分享你的想法...") },
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 150.dp)
                .padding(horizontal = Spacing.LG),
            shape = RoundedCornerShape(CornerRadius.SM),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = AppColors.bgPrimaryLight,
                focusedContainerColor = AppColors.bgPrimaryLight,
                unfocusedBorderColor = androidx.compose.ui.graphics.Color.Transparent,
                focusedBorderColor = androidx.compose.ui.graphics.Color.Transparent
            )
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.MD),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            CreationToolButton(icon = Icons.Default.PhotoLibrary, label = "相册")
            CreationToolButton(icon = Icons.Default.CameraAlt, label = "拍照")
            CreationToolButton(icon = Icons.Default.Mic, label = "语音")
            CreationToolButton(icon = Icons.Default.LocationOn, label = "位置")
        }

        Spacer(modifier = Modifier.weight(1f))

        AppButton(
            text = "发布",
            onClick = onDismiss,
            variant = ButtonVariant.Primary,
            size = ButtonSize.Large,
            modifier = Modifier
                .padding(horizontal = Spacing.LG)
                .padding(bottom = Spacing.LG)
        )
    }
}

@Composable
private fun CreationToolButton(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        IconButton(onClick = { }) {
            Icon(icon, contentDescription = label, tint = AppColors.textSecondaryLight)
        }
        Text(label, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
    }
}
