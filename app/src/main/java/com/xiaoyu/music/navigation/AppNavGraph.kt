package com.xiaoyu.music.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

/**
 * 应用导航图。
 *
 * V0.5 暂时只有 Welcome 入口;后续 commit 会逐步加:
 * - feature/home/HomeScreen
 * - feature/library-local/LibraryScreen
 * - feature/player/PlayerScreen
 * - feature/settings/SettingsScreen
 */
@Composable
fun AppNavGraph(
    navController: NavHostController = rememberNavController(),
) {
    NavHost(
        navController = navController,
        startDestination = Routes.WELCOME,
    ) {
        composable(Routes.WELCOME) {
            com.xiaoyu.music.WelcomeScreen()
        }
    }
}

/**
 * 路由常量集中管理。
 */
object Routes {
    const val WELCOME = "welcome"
    const val HOME = "home"
    const val LIBRARY = "library"
    const val PLAYER = "player"
    const val SETTINGS = "settings"
}
