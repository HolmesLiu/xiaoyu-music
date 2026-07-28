package com.xiaoyu.music

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.xiaoyu.music.core.ui.theme.builtin.XiaoyuTheme
import dagger.hilt.android.AndroidEntryPoint

/**
 * 主 Activity,Compose 入口。
 *
 * 1. 安装 Android 12+ SplashScreen API
 * 2. Edge-to-edge 全屏
 * 3. 主题 + 启动页
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // SplashScreen API:必须在 super.onCreate 之前调用
        installSplashScreen()
        super.onCreate(savedInstanceState)

        // Edge-to-edge
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(0, 0),
            navigationBarStyle = SystemBarStyle.auto(0, 0),
        )

        setContent {
            XiaoyuTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    // V0.5 临时:启动页,后续替换为 AppNavGraph
                    WelcomeScreen()
                }
            }
        }
    }
}
