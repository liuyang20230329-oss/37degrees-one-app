package com.thirtysevendegrees.app.features.auth.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.thirtysevendegrees.app.designsystem.atoms.*
import com.thirtysevendegrees.app.designsystem.tokens.*

@Composable
fun AuthScreen(
    onLoginSuccess: () -> Unit,
    modifier: Modifier = Modifier
) {
    var isSignUp by remember { mutableStateOf(false) }
    var phone by remember { mutableStateOf("") }
    var verificationCode by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var nickname by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = Spacing.LG)
            .padding(top = 120.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "37°",
            style = MaterialTheme.typography.displayLarge,
            color = AppColors.brandPrimary
        )
        Spacer(modifier = Modifier.height(Spacing.SM))
        Text("温度与信任", style = MaterialTheme.typography.bodyMedium, color = AppColors.textSecondaryLight)
        Spacer(modifier = Modifier.height(Spacing.XXL))

        AppTextField(
            value = phone,
            onValueChange = { phone = it },
            placeholder = "手机号",
            maxLength = 11
        )
        Spacer(modifier = Modifier.height(Spacing.MD))

        if (isSignUp) {
            Row(horizontalArrangement = Arrangement.spacedBy(Spacing.SM)) {
                AppTextField(
                    value = verificationCode,
                    onValueChange = { verificationCode = it },
                    placeholder = "验证码",
                    maxLength = 6,
                    modifier = Modifier.weight(1f)
                )
                AppButton(
                    text = "获取验证码",
                    onClick = { },
                    variant = ButtonVariant.Outline,
                    size = ButtonSize.Small,
                    modifier = Modifier.width(110.dp)
                )
            }
            Spacer(modifier = Modifier.height(Spacing.MD))
        }

        AppTextField(
            value = password,
            onValueChange = { password = it },
            placeholder = "密码",
            maxLength = 20
        )
        Spacer(modifier = Modifier.height(Spacing.MD))

        if (isSignUp) {
            AppTextField(
                value = nickname,
                onValueChange = { nickname = it },
                placeholder = "昵称",
                maxLength = 20
            )
            Spacer(modifier = Modifier.height(Spacing.MD))
        }

        AppButton(
            text = if (isSignUp) "注册" else "登录",
            onClick = onLoginSuccess,
            variant = ButtonVariant.Primary,
            size = ButtonSize.Large,
            isLoading = isLoading
        )
        Spacer(modifier = Modifier.height(Spacing.LG))

        Row(
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                if (isSignUp) "已有账号？" else "没有账号？",
                style = MaterialTheme.typography.bodySmall,
                color = AppColors.textSecondaryLight
            )
            Spacer(modifier = Modifier.width(Spacing.XXS))
            Text(
                if (isSignUp) "去登录" else "立即注册",
                style = MaterialTheme.typography.bodySmall,
                color = AppColors.brandPrimary,
                modifier = Modifier.clickable { isSignUp = !isSignUp }
            )
        }
    }
}

private fun Modifier.clickable(onClick: () -> Unit): Modifier =
    this.then(androidx.compose.foundation.clickable(onClick = onClick))
