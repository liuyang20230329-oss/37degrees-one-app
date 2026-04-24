package com.thirtysevendegrees.app.features.chat.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.AppIconButton
import com.thirtysevendegrees.app.designsystem.molecules.ChatBubble
import com.thirtysevendegrees.app.designsystem.tokens.*

data class ChatMessage(
    val id: String,
    val text: String,
    val isOwn: Boolean,
    val time: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatDetailScreen(
    conversationId: String,
    username: String,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    var messages by remember {
        mutableStateOf(
            listOf(
                ChatMessage("1", "你好，很高兴认识你！", false, "10:00"),
                ChatMessage("2", "你好！我也是", true, "10:01"),
                ChatMessage("3", "最近有什么有趣的动态吗？", false, "10:02"),
                ChatMessage("4", "有很多呢，你可以看看首页推荐", true, "10:03")
            )
        )
    }
    var inputText by remember { mutableStateOf("") }
    val listState = rememberLazyListState()

    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    Column(modifier = modifier.fillMaxSize()) {
        AppNavigationBar(
            title = username,
            onBack = onBack,
            modifier = Modifier.fillMaxWidth()
        )

        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .padding(vertical = Spacing.SM),
            verticalArrangement = Arrangement.spacedBy(Spacing.MD)
        ) {
            items(messages) { msg ->
                ChatBubble(
                    message = msg.text,
                    isOwn = msg.isOwn,
                    time = msg.time,
                    showAvatar = !msg.isOwn,
                    senderName = username
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.bgPrimaryLight)
                .padding(horizontal = Spacing.LG, vertical = Spacing.SM),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Mic,
                contentDescription = null,
                tint = AppColors.textTertiaryLight,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(Spacing.SM))
            OutlinedTextField(
                value = inputText,
                onValueChange = { inputText = it },
                placeholder = { Text("输入消息...") },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(CornerRadius.SM),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = AppColors.bgTertiaryLight,
                    focusedContainerColor = AppColors.bgTertiaryLight
                )
            )
            Spacer(modifier = Modifier.width(Spacing.SM))
            if (inputText.isNotEmpty()) {
                IconButton(onClick = {
                    messages = messages + ChatMessage(
                        id = java.util.UUID.randomUUID().toString(),
                        text = inputText,
                        isOwn = true,
                        time = "刚刚"
                    )
                    inputText = ""
                }) {
                    Icon(
                        Icons.Default.ArrowUpward,
                        contentDescription = "发送",
                        tint = AppColors.brandPrimary,
                        modifier = Modifier.size(28.dp)
                    )
                }
            } else {
                Icon(
                    imageVector = Icons.Default.AddCircle,
                    contentDescription = null,
                    tint = AppColors.textTertiaryLight,
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}
