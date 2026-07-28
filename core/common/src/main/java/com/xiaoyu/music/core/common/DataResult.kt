package com.xiaoyu.music.core.common

/**
 * 通用数据结果包装,用于跨模块数据传输。
 */
sealed interface DataResult<out T> {
    data class Success<T>(val data: T) : DataResult<T>
    data class Error(val throwable: Throwable) : DataResult<Nothing>
}

inline fun <T, R> DataResult<T>.map(transform: (T) -> R): DataResult<R> = when (this) {
    is DataResult.Success -> DataResult.Success(transform(data))
    is DataResult.Error -> this
}

inline fun <T> DataResult<T>.onSuccess(block: (T) -> Unit): DataResult<T> {
    if (this is DataResult.Success) block(data)
    return this
}

inline fun <T> DataResult<T>.onFailure(block: (Throwable) -> Unit): DataResult<T> {
    if (this is DataResult.Error) block(throwable)
    return this
}
