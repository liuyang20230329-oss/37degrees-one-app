package com.thirtysevendegrees.app.designsystem.molecules

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun SearchBar(
    placeholder: String,
    onTap: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(40.dp)
            .clip(RoundedCornerShape(CornerRadius.MD))
            .background(AppColors.bgTertiaryLight)
            .clickable(onClick = onTap)
            .padding(horizontal = Spacing.MD),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Default.Search,
            contentDescription = null,
            tint = AppColors.textTertiaryLight,
            modifier = Modifier.size(IconSize.SM)
        )
        Spacer(modifier = Modifier.width(Spacing.SM))
        Text(
            text = placeholder,
            style = MaterialTheme.typography.bodySmall,
            color = AppColors.textTertiaryLight
        )
    }
}
