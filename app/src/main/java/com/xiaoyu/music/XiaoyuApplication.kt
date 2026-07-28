package com.xiaoyu.music

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * 小雨音乐 Application 入口。
 *
 * `@HiltAndroidApp` 触发 Hilt 的代码生成,作为整个应用的 DI 容器根。
 */
@HiltAndroidApp
class XiaoyuApplication : Application()
