package com.xiaoyu.music.core.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable

/**
 * 应用主题抽象。
 *
 * **不要写死颜色 / 圆角 / 字体**——所有 UI 必须从当前 [AppTheme] 拿。
 * 后续添加多套主题或主题包时,只新增 [AppTheme] 实现,业务代码零改动。
 */
data class AppTheme(
    val id: String,
    val name: String,
    val colorScheme: ColorScheme,
    val typography: Typography,
    val shapes: Shapes,
)

/**
 * 当前主题访问入口。
 *
 * @throws IllegalStateException 如果在没提供 LocalAppTheme 的 Composable 内访问
 */
object AppThemeTokens {
    val current: AppTheme
        @Composable
        @ReadOnlyComposable
        get() = LocalAppTheme.current
}
