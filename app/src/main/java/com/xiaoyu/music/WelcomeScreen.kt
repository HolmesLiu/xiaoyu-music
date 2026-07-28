package com.xiaoyu.music

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.xiaoyu.music.core.ui.theme.AppThemeTokens
import com.xiaoyu.music.core.ui.theme.LocalSpacing

/**
 * V0.5 临时启动页。
 *
 * 功能:展示 App 名称 + 当前阶段 + 主题色取色示意。
 * 后续 commit 会替换为 AppNavGraph(导航图 + 多个 feature 页面)。
 */
@Composable
fun WelcomeScreen() {
    val theme = AppThemeTokens.current
    val spacing = LocalSpacing.current

    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(spacing.xl),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = "小雨音乐",
                style = MaterialTheme.typography.titleLarge,
                color = theme.colorScheme.primary,
            )
            Spacer(modifier = Modifier.height(spacing.sm))
            Text(
                text = "Xiaoyu Music",
                style = MaterialTheme.typography.bodyLarge,
                color = theme.colorScheme.onBackground,
            )
            Spacer(modifier = Modifier.height(spacing.xxl))
            Text(
                text = "V0.5 工程脚手架",
                style = MaterialTheme.typography.bodyLarge,
                color = theme.colorScheme.onSurfaceVariant,
            )
            Spacer(modifier = Modifier.height(spacing.xs))
            Text(
                text = "主题: ${theme.name}",
                style = MaterialTheme.typography.bodyLarge,
                color = theme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
