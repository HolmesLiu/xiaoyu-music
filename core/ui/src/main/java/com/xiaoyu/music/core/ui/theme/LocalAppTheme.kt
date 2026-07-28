package com.xiaoyu.music.core.ui.theme

import androidx.compose.runtime.compositionLocalOf

/**
 * 全局主题访问。
 *
 * 使用方式:`AppThemeTokens.current.colorScheme.primary`,**禁止** `Color(0xFF...)`。
 */
val LocalAppTheme = compositionLocalOf<AppTheme> {
    error(
        "AppTheme not provided. Wrap your UI in AppThemeProvider { ... } " +
            "or setTheme(currentTheme) in MainActivity."
    )
}
