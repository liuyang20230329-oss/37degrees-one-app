package com.thirtysevendegrees.app.features.profile.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.AppButton
import com.thirtysevendegrees.app.designsystem.atoms.Avatar
import com.thirtysevendegrees.app.designsystem.atoms.ButtonSize
import com.thirtysevendegrees.app.designsystem.atoms.ButtonVariant
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun ProfileScreen(
    onSettingsClick: () -> Unit,
    onEditProfileClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("动态", "相册", "收藏")

    Column(modifier = modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("我的", style = MaterialTheme.typography.headlineMedium, modifier = Modifier.weight(1f))
        }

        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(Spacing.XXL))
            Avatar(url = null, size = AvatarSize.XXL, placeholder = "我")
            Spacer(modifier = Modifier.height(Spacing.MD))
            Text("用户名", style = MaterialTheme.typography.displaySmall, color = AppColors.textPrimaryLight)
            Text("@username", style = MaterialTheme.typography.bodySmall, color = AppColors.textTertiaryLight)
            Spacer(modifier = Modifier.height(Spacing.XS))
            Text("这是个人简介，分享生活中的点滴",
                style = MaterialTheme.typography.bodySmall, color = AppColors.textSecondaryLight)
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = Spacing.MD),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            StatItem(count = 128, label = "关注")
            StatItem(count = 256, label = "粉丝")
            StatItem(count = 1024, label = "获赞")
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG),
            horizontalArrangement = Arrangement.spacedBy(Spacing.SM)
        ) {
            AppButton(text = "编辑资料", onClick = onEditProfileClick, variant = ButtonVariant.Outline, size = ButtonSize.Medium, modifier = Modifier.weight(1f))
            AppButton(text = "分享", onClick = { }, variant = ButtonVariant.Ghost, size = ButtonSize.Medium, modifier = Modifier.weight(1f))
        }

        Spacer(modifier = Modifier.height(Spacing.LG))

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            tabs.forEachIndexed { index, title ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .weight(1f)
                        .clickable { selectedTab = index }
                        .padding(vertical = Spacing.XS)
                ) {
                    Text(title, style = if (selectedTab == index) MaterialTheme.typography.labelMedium else MaterialTheme.typography.bodySmall,
                        color = if (selectedTab == index) AppColors.textPrimaryLight else AppColors.textTertiaryLight)
                    Spacer(modifier = Modifier.height(Spacing.XS))
                    Box(modifier = Modifier.height(2.dp).fillMaxWidth(0.5f)
                        .background(if (selectedTab == index) AppColors.brandPrimary else androidx.compose.ui.graphics.Color.Transparent))
                }
            }
        }

        LazyVerticalGrid(
            columns = GridCells.Fixed(3),
            modifier = Modifier
                .fillMaxSize()
                .padding(Spacing.LG),
            horizontalArrangement = Arrangement.spacedBy(2.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            items((1..9).toList()) {
                Box(
                    modifier = Modifier
                        .aspectRatio(1f)
                        .clip(RoundedCornerShape(CornerRadius.XS))
                        .background(AppColors.bgTertiaryLight)
                )
            }
        }
    }
}

@Composable
private fun StatItem(count: Int, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("$count", style = MaterialTheme.typography.headlineMedium, color = AppColors.textPrimaryLight)
        Text(label, style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
    }
}
