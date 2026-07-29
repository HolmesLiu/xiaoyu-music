import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/env/env_keys.dart';
import '../../core/logging/app_logger.dart';

/// 启动欢迎页(Phase 1 占位)。
///
/// V0.1 阶段仅展示:
/// - App 名称
/// - 版本
/// - 关键 Phase 进度
/// - Navidrome 凭据是否已配置
/// - 跳转到"功能开发"按钮(Phase 2+ 替换为本地库 / 搜索 / 设置等真实入口)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppConfig.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Xiaoyu Music',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'v${AppConfig.appVersion} · Phase 1 脚手架',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '开发进度',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _PhaseRow(label: 'Phase 1 — Flutter 脚手架', done: true),
                      _PhaseRow(label: 'Phase 2 — 本地音乐扫描', done: false),
                      _PhaseRow(label: 'Phase 3 — 播放器核心', done: false),
                      _PhaseRow(label: 'Phase 4 — Navidrome 集成', done: false),
                      _PhaseRow(label: 'Phase 5 — NAS (SMB/WebDAV)', done: false),
                      _PhaseRow(label: 'Phase 6 — 统一搜索', done: false),
                      _PhaseRow(label: 'Phase 7 — 下载系统', done: false),
                      _PhaseRow(label: 'Phase 8 — 同步系统', done: false),
                      _PhaseRow(label: 'Phase 9 — 缓存管理', done: false),
                      _PhaseRow(label: 'Phase 10 — 多端适配', done: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navidrome 凭据',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _ConfigRow(
                        label: 'URL',
                        value: EnvKeys.navidromeUrl.isEmpty
                            ? '(未配置)'
                            : EnvKeys.navidromeUrl,
                      ),
                      _ConfigRow(
                        label: 'User',
                        value: EnvKeys.navidromeUser.isEmpty
                            ? '(未配置)'
                            : EnvKeys.navidromeUser,
                      ),
                      _ConfigRow(
                        label: 'Pass',
                        value: EnvKeys.navidromePass.isEmpty
                            ? '(未配置)'
                            : '••••••••',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () {
                  AppLogger.i('Welcome', 'User tapped "功能开发"');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phase 2+ 功能开发中...'),
                    ),
                  );
                },
                child: const Text('功能开发中(下一 Phase)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.label, required this.done});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: done
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
