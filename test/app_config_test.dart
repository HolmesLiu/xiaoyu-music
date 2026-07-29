import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyu_music/core/config/app_config.dart';
import 'package:xiaoyu_music/core/env/env_keys.dart';

void main() {
  group('AppConfig', () {
    test('isNavidromeConfigured 返回 false 当凭据为空', () {
      // 默认空 dart-define,凭据为空
      expect(AppConfig.isNavidromeConfigured, isFalse);
    });

    test('appName / appVersion 非空', () {
      expect(AppConfig.appName, isNotEmpty);
      expect(AppConfig.appVersion, isNotEmpty);
    });
  });

  group('EnvKeys', () {
    test('Navidrome 默认值是空字符串(强制走 --dart-define)', () {
      expect(EnvKeys.navidromeUrl, '');
      expect(EnvKeys.navidromeUser, '');
      expect(EnvKeys.navidromePass, '');
    });

    test('下载/缓存目录名有合理默认值', () {
      expect(EnvKeys.downloadDirName, contains('XiaoyuMusic'));
      expect(EnvKeys.cacheDirName, contains('XiaoyuMusic'));
    });
  });
}
