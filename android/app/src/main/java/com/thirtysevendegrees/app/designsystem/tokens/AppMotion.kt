package com.thirtysevendegrees.app.designsystem.tokens

import androidx.compose.animation.core.TweenSpec
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring

object AppDuration {
    const val INSTANT = 100
    const val FAST = 200
    const val NORMAL = 300
    const val SLOW = 500
    const val GLACIAL = 800
}

object AppAnimationSpec {
    fun <T> instant() = TweenSpec<T>(durationMillis = AppDuration.INSTANT)
    fun <T> fast() = TweenSpec<T>(durationMillis = AppDuration.FAST)
    fun <T> normal() = TweenSpec<T>(durationMillis = AppDuration.NORMAL)
    fun <T> slow() = TweenSpec<T>(durationMillis = AppDuration.SLOW)
    fun <T> spring() = spring<T>(dampingRatio = 0.8f, stiffness = Spring.StiffnessMedium)
}
