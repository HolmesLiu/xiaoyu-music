import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../database/library_repository.dart';
import '../../providers/providers.dart';

/// 本地音乐库页面 — V0.2 (Phase 2) 主界面。
///
/// 状态:
/// - 顶部 AppBar + 刷新按钮 + 扫描状态
/// - 权限未授予时:大按钮"申请权限"(on_audio_query 内部触发系统弹窗)
/// - 扫描中:全屏 loading
/// - 扫描失败:错误信息 + 重试
/// - 扫描成功且库为空:Empty 提示
/// - 扫描成功且有歌:ListView(SongWithSource 列表)
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static const String _tag = 'LibraryScreen';

  @override
  void initState() {
    super.initState();
    // 进入页面触发一次扫描
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.i(_tag, 'initState → trigger first scan');
      ref.read(localLibraryScannerProvider.notifier).scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(localLibraryScannerProvider);
    final songsAsync = ref.watch(allSongsStreamProvider);
    final statsAsync = ref.watch(libraryStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('本地音乐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新扫描',
            onPressed: () {
              AppLogger.i(_tag, 'User tapped refresh');
              ref.read(localLibraryScannerProvider.notifier).scan();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: _StatsBar(statsAsync: statsAsync, scanState: scanState),
        ),
      ),
      body: switch (scanState) {
        ScanPermissionDenied() => _PermissionRequest(
            onRequest: () =>
                ref.read(localLibraryScannerProvider.notifier).scan(),
          ),
        ScanRunning() => const _CenteredLoading(message: '正在扫描本地音乐…'),
        ScanFailed(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                ref.read(localLibraryScannerProvider.notifier).scan(),
          ),
        ScanSuccess() || ScanIdle() => songsAsync.when(
            data: (songs) => songs.isEmpty
                ? const _EmptyView()
                : _SongList(songs: songs),
            loading: () =>
                const _CenteredLoading(message: '正在加载歌曲…'),
            error: (e, _) => _ErrorView(
              message: '加载失败: $e',
              onRetry: () =>
                  ref.read(localLibraryScannerProvider.notifier).scan(),
            ),
          ),
      },
    );
  }
}

// ============================ 组件 ============================

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.statsAsync, required this.scanState});
  final AsyncValue<LibraryStats> statsAsync;
  final ScanState scanState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = statsAsync.valueOrNull;
    final status = switch (scanState) {
      ScanIdle() => '未扫描',
      ScanRunning() => '扫描中…',
      ScanSuccess(:final importedCount, :final lastScanAt) =>
        '上次扫描: $importedCount 首'
            '${lastScanAt != null ? " · ${_fmtTime(lastScanAt)}" : ""}',
      ScanFailed() => '扫描失败',
      ScanPermissionDenied() => '需要权限',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Text(
        stats == null
            ? status
            : '$status  ·  ${stats.songCount} 首 / ${stats.albumCount} 专辑 / ${stats.artistCount} 艺人',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _fmtTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    return '${diff.inDays} 天前';
  }
}

class _SongList extends StatelessWidget {
  const _SongList({required this.songs});
  final List<SongWithSource> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: songs.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final sws = songs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.music_note,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(sws.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${sws.artist}  ·  ${sws.album}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _fmtDuration(sws.durationMs),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            AppLogger.i('Library', 'Tapped song: ${sws.title} (id=${sws.id})');
            // Phase 3 接播放
          },
        );
      },
    );
  }

  String _fmtDuration(int ms) {
    final sec = ms ~/ 1000;
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _CenteredLoading extends StatelessWidget {
  const _CenteredLoading({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('本地音乐库里没有可播放的歌曲'),
            const SizedBox(height: 8),
            const Text(
              '把音乐文件放到设备存储里,然后点右上角刷新',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重新扫描'),
              onPressed: () {
                // 用 ProviderListener 不好,直接在按钮里调
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRequest extends StatelessWidget {
  const _PermissionRequest({required this.onRequest});
  final VoidCallback onRequest;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_shared, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '需要授予读取音乐权限',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '扫描本地音乐需要 READ_MEDIA_AUDIO / READ_EXTERNAL_STORAGE 权限',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.lock_open),
              label: const Text('申请权限'),
              onPressed: onRequest,
            ),
          ],
        ),
      ),
    );
  }
}
