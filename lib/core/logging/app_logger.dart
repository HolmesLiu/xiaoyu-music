import 'package:logger/logger.dart';

/// 应用全局日志器(单例)。
///
/// 使用方式:
/// ```dart
/// AppLogger.i('MyTag', 'something happened');
/// AppLogger.e('MyTag', 'failed', error: e, stackTrace: st);
/// ```
///
/// 设计:
/// - 进程级单例,所有模块共享同一个 [Logger] 实例
/// - 输出到 stdout(Debug 模式) / 写入日志文件(Release 模式,Phase 1 暂未实现)
/// - 日志等级过滤:Debug 模式看 DEBUG+,Release 模式看 INFO+
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 不打印调用栈行,保持简洁
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kReleaseMode ? Level.info : Level.debug,
  );

  static void d(String tag, String message) =>
      _logger.d('[$tag] $message');

  static void i(String tag, String message) =>
      _logger.i('[$tag] $message');

  static void w(String tag, String message, {Object? error}) =>
      _logger.w('[$tag] $message${_fmtErr(error)}');

  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(
        '[$tag] $message${_fmtErr(error)}',
        error: error,
        stackTrace: stackTrace,
      );

  static String _fmtErr(Object? error) => error == null ? '' : ' | $error';
}

/// 占位导出,避免 `kReleaseMode` 没引用。Phase 1 不需要区分 Debug/Release,
/// 但保留扩展点。
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
