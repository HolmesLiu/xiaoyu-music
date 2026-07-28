package com.xiaoyu.music.core.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * 占位颜色——**禁止业务代码直接使用这些常量**。
 * 业务代码请用 `AppThemeTokens.current.colorScheme.xxx`。
 *
 * 这里只作为 Material 3 ColorScheme 构造的输入。
 */
internal object ThemeDefaults {
    val Purple80 = Color(0xFFD0BCFF)
    val PurpleGrey80 = Color(0xFFCCC2DC)
    val Pink80 = Color(0xFFEFB8C8)

    val Purple40 = Color(0xFF6650A4)
    val PurpleGrey40 = Color(0xFF625B71)
    val Pink40 = Color(0xFF7D5260)

    val DarkBackground = Color(0xFF1C1B1F)
    val LightBackground = Color(0xFFFFFBFE)
}
