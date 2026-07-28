package com.xiaoyu.music.core.ui.theme

import kotlinx.coroutines.flow.StateFlow

/**
 * 主题仓库接口。
 *
 * V1.0 只内置 1 套主题(Material You),但接口必须这样设计——以后加多套时零业务改动。
 */
interface ThemeRepository {
    /** 当前主题 */
    val current: StateFlow<AppTheme>

    /** 所有可用主题(列表里只有 1 项也合法) */
    val available: StateFlow<List<AppTheme>>

    /** 切换主题 */
    fun setTheme(id: String)

    /** 注册新主题(预留,主题包加载时用) */
    fun register(theme: AppTheme)
}
