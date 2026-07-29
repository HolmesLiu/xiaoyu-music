import '../env/env_keys.dart';
import '../logging/app_logger.dart';

/// 应用配置聚合。
///
/// 阶段 1 实现:基本只读环境变量,把启动期不可变的全局配置集中起来。
/// 后续 Phase 会扩展:用户设置(主题/默认播放质量/缓存策略)等需要持久化的配置
/// 会通过 Drift 或 shared_preferences 走另外的 `UserPreferences`。
class AppConfig {
  AppConfig._();

  static const String _tag = 'AppConfig';

  static bool get isNavidromeConfigured =>
      EnvKeys.navidromeUrl.isNotEmpty &&
      EnvKeys.navidromeUser.isNotEmpty &&
      EnvKeys.navidromePass.isNotEmpty;

  /// 应用版本号(从 pubspec.yaml 读不进来,Dart 端写死,Phase 1 占位)
  static const String appVersion = '0.1.0+1';
  static const String appName = '小雨音乐';

  /// 启动期打印一次,方便 debug 时确认配置是否到位
  static void logBootConfig() {
    AppLogger.i(_tag, '======================================');
    AppLogger.i(_tag, '$appName v$appVersion');
    AppLogger.i(_tag, 'Navidrome configured: $isNavidromeConfigured');
    AppLogger.i(_tag, '  URL:  ${isNavidromeConfigured ? EnvKeys.navidromeUrl : "(empty)"}');
    AppLogger.i(_tag, '  User: ${isNavidromeConfigured ? EnvKeys.navidromeUser : "(empty)"}');
    AppLogger.i(_tag, 'Download dir name: ${EnvKeys.downloadDirName}');
    AppLogger.i(_tag, 'Cache dir name:    ${EnvKeys.cacheDirName}');
    AppLogger.i(_tag, '======================================');
  }
}
