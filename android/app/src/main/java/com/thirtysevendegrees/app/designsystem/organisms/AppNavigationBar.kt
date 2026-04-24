package com.thirtysevendegrees.app.designsystem.organisms

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.Spacing

data class NavAction(
    val icon: ImageVector,
    val onClick: () -> Unit
)

@Composable
fun AppNavigationBar(
    title: String,
    onBack: (() -> Unit)? = null,
    rightActions: List<NavAction> = emptyList(),
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .padding(horizontal = Spacing.LG),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (onBack != null) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "返回")
            }
        } else {
            Spacer(modifier = Modifier.width(48.dp))
        }

        Spacer(modifier = Modifier.weight(1f))

        Text(title, style = MaterialTheme.typography.headlineMedium)

        Spacer(modifier = Modifier.weight(1f))

        rightActions.forEach { action ->
            IconButton(onClick = action.onClick) {
                Icon(action.icon, contentDescription = null)
            }
        }
        if (rightActions.isEmpty()) {
            Spacer(modifier = Modifier.width(48.dp))
        }
    }
}
