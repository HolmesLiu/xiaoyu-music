/// 环境变量 / 凭据 key 集中管理。
///
/// 所有 Navidrome / NAS / 落雪等敏感配置都从这里读取,
/// 实际值通过 `flutter build apk --dart-define` 或 `--dart-define-from-file`
/// 注入,绝不进 Git。
///
/// 注入方式示例:
///   flutter build apk \
///     --dart-define=NAVIDROME_URL=http://192.168.100.9:4533/ \
///     --dart-define=NAVIDROME_USER=dayu \
///     --dart-define=NAVIDROME_PASS=xxx
///
/// 或在 `local.properties` 里:
///   navidrome.url=http://192.168.100.9:4533/
///   navidrome.user=dayu
///   navidrome.pass=xxx
/// 然后在 build 脚本里转成 --dart-define。
class EnvKeys {
  EnvKeys._();

  // ---- Navidrome (Subsonic API) ----
  static const String navidromeUrl = String.fromEnvironment(
    'NAVIDROME_URL',
    defaultValue: '',
  );
  static const String navidromeUser = String.fromEnvironment(
    'NAVIDROME_USER',
    defaultValue: '',
  );
  static const String navidromePass = String.fromEnvironment(
    'NAVIDROME_PASS',
    defaultValue: '',
  );

  // ---- NAS (Phase 5) ----
  // 留空,Phase 5 实装

  // ---- 落雪 (Phase 6/7) ----
  // 留空,Phase 6 实装

  // ---- 应用行为 ----
  static const String downloadDirName = String.fromEnvironment(
    'DOWNLOAD_DIR_NAME',
    defaultValue: 'XiaoyuMusic/Downloads',
  );
  static const String cacheDirName = String.fromEnvironment(
    'CACHE_DIR_NAME',
    defaultValue: 'XiaoyuMusic/Cache',
  );
}
