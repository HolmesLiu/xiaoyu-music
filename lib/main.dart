import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'database/app_database.dart';
import 'ui/screens/welcome_screen.dart';

/// 启动入口
///
/// 启动顺序(顺序敏感):
/// 1. 初始化日志
/// 2. 启动 Drift 数据库
/// 3. 包裹 Riverpod scope
/// 4. 启动主题 + 首页
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.i('Main', 'Booting ${AppConfig.appName} v${AppConfig.appVersion}');
  AppConfig.logBootConfig();
  // ignore: unused_local_variable
  final _db = AppDatabase.bootstrap();

  runApp(
    const ProviderScope(
      child: XiaoyuMusicApp(),
    ),
  );
}

class XiaoyuMusicApp extends StatelessWidget {
  const XiaoyuMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4A6CF7),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
