package com.xiaoyu.music.core.common

import javax.inject.Qualifier
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

/**
 * 协程调度器,用于依赖注入时区分 IO / Default / Main。
 */
enum class AppDispatchers(val dispatcher: CoroutineDispatcher) {
    Main(Dispatchers.Main),
    IO(Dispatchers.IO),
    Default(Dispatchers.Default),
}

@Retention(AnnotationRetention.RUNTIME)
@Qualifier
annotation class Dispatcher(val appDispatcher: AppDispatchers)
