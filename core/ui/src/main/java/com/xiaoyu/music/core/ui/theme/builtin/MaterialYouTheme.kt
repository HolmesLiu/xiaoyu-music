package com.xiaoyu.music.core.ui.theme.builtin

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalContext
import com.xiaoyu.music.core.ui.theme.AppShapes
import com.xiaoyu.music.core.ui.theme.AppTheme
import com.xiaoyu.music.core.ui.theme.AppTypography
import com.xiaoyu.music.core.ui.theme.LocalAppTheme
import com.xiaoyu.music.core.ui.theme.LocalSpacing
import com.xiaoyu.music.core.ui.theme.Spacing
import com.xiaoyu.music.core.ui.theme.ThemeDefaults

/**
 * Material You 默认主题(Android 12+ 动态取色,低版本走静态 fallback)。
 *
 * V1.0 唯一内置主题。
 */
object MaterialYouTheme {
    const val ID = "material_you"
    const val NAME = "Material You"

    @Composable
    fun Build(
        darkTheme: Boolean = isSystemInDarkTheme(),
        dynamicColor: Boolean = true,
    ): AppTheme {
        val context = LocalContext.current
        val colorScheme = when {
            dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
                if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
            }
            darkTheme -> darkColorSchemeDefaults()
            else -> lightColorSchemeDefaults()
        }
        return AppTheme(
            id = ID,
            name = NAME,
            colorScheme = colorScheme,
            typography = AppTypography,
            shapes = AppShapes,
        )
    }

    private fun lightColorSchemeDefaults() = lightColorScheme(
        primary = ThemeDefaults.Purple40,
        secondary = ThemeDefaults.PurpleGrey40,
        tertiary = ThemeDefaults.Pink40,
    )

    private fun darkColorSchemeDefaults() = darkColorScheme(
        primary = ThemeDefaults.Purple80,
        secondary = ThemeDefaults.PurpleGrey80,
        tertiary = ThemeDefaults.Pink80,
    )
}

/**
 * 应用主题 Composable 包装。
 *
 * 用法:
 * ```
 * XiaoyuTheme {
 *   Scaffold { ... }
 * }
 * ```
 */
@Composable
fun XiaoyuTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit,
) {
    val theme = MaterialYouTheme.Build(darkTheme = darkTheme, dynamicColor = dynamicColor)
    CompositionLocalProvider(
        LocalAppTheme provides theme,
        LocalSpacing provides Spacing(),
    ) {
        MaterialTheme(
            colorScheme = theme.colorScheme,
            typography = theme.typography,
            shapes = theme.shapes,
            content = content,
        )
    }
}
