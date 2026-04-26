package com.thirtysevendegrees.app.features.discover.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.*
import com.thirtysevendegrees.app.designsystem.molecules.SearchBar
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun DiscoverScreen(
    onSearchClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedTag by remember { mutableStateOf("全部") }
    val tags = listOf("全部", "热门", "附近", "话题", "用户", "视频")

    Column(modifier = modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("发现", style = MaterialTheme.typography.headlineMedium)
        }

        SearchBar(placeholder = "搜索用户、话题、内容...", onTap = onSearchClick,
            modifier = Modifier.padding(horizontal = Spacing.LG, vertical = Spacing.SM))

        LazyRow(
            contentPadding = PaddingValues(horizontal = Spacing.LG),
            horizontalArrangement = Arrangement.spacedBy(Spacing.SM)
        ) {
            items(tags) { tag ->
                Tag(title = tag, isSelected = tag == selectedTag, onClick = { selectedTag = tag })
            }
        }
        Spacer(modifier = Modifier.height(Spacing.SM))

        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = Spacing.LG),
            verticalArrangement = Arrangement.spacedBy(Spacing.MD)
        ) {
            item {
                DiscoveryCard(title = "热门话题") {
                    (1..5).forEach { i ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = Spacing.XS),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("$i", style = MaterialTheme.typography.labelSmall,
                                color = if (i <= 3) AppColors.brandPrimary else AppColors.textTertiaryLight)
                            Spacer(modifier = Modifier.width(Spacing.SM))
                            Text("#热门话题$i", style = MaterialTheme.typography.bodyMedium, color = AppColors.textPrimaryLight)
                            Spacer(modifier = Modifier.weight(1f))
                            Text("${i * 100}讨论", style = MaterialTheme.typography.labelSmall, color = AppColors.textTertiaryLight)
                        }
                    }
                }
            }
            item {
                DiscoveryCard(title = "推荐用户") {
                    (1..5).forEach { i ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = Spacing.XS),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Avatar(url = null, size = AvatarSize.MD, placeholder = "用$i")
                            Spacer(modifier = Modifier.width(Spacing.SM))
                            Column(modifier = Modifier.weight(1f)) {
                                Text("推荐用户$i", style = MaterialTheme.typography.bodyMedium, color = AppColors.textPrimaryLight)
                                Text("这是用户简介...", style = MaterialTheme.typography.labelSmall, color = AppColors.textSecondaryLight)
                            }
                            AppButton(text = "关注", onClick = { }, variant = ButtonVariant.Secondary, size = ButtonSize.Small, modifier = Modifier.width(70.dp))
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun DiscoveryCard(title: String, content: @Composable () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CornerRadius.MD)
            .background(AppColors.bgSecondaryLight)
            .padding(Spacing.MD)
    ) {
        Text(title, style = MaterialTheme.typography.displaySmall, color = AppColors.textPrimaryLight)
        Spacer(modifier = Modifier.height(Spacing.SM))
        content()
    }
}
