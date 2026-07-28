package com.xiaoyu.music.core.ui.theme

import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * 间距系统(预留接口,V1.0 全部走默认常量)。
 *
 * **业务代码请用 `LocalSpacing.current.xs` 等,不要写 `Modifier.padding(16.dp)`。**
 *
 * V2.0+ 用户调色 / 主题包生效时,这套数据会被主题覆盖。
 */
data class Spacing(
    val none: Dp = 0.dp,
    val xxs: Dp = 2.dp,
    val xs: Dp = 4.dp,
    val sm: Dp = 8.dp,
    val md: Dp = 12.dp,
    val lg: Dp = 16.dp,
    val xl: Dp = 20.dp,
    val xxl: Dp = 24.dp,
    val xxxl: Dp = 32.dp,
    val huge: Dp = 48.dp,
)

internal val DefaultSpacing = Spacing()

val LocalSpacing = compositionLocalOf { DefaultSpacing }
