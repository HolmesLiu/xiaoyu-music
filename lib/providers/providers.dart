import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/library_repository.dart';
import 'local/local_music_provider.dart';
import 'music_core.dart';

// =============================================================================
// V0.2 Riverpod 依赖图
//
//   appDatabaseProvider
//         │
//         ▼
//   libraryRepositoryProvider
//         │
//         ▼
//   localMusicProviderProvider (Phase 2: 只有 Local)
//         │
//         ▼
//   musicCoreProvider
//         │
//         ▼
//   allSongsStreamProvider / libraryStatsProvider  (UI 订阅)
// =============================================================================

/// 全局单例 — `AppDatabase.bootstrap()` 在 main() 已先调过
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(appDatabaseProvider));
});

/// Local 音乐 Provider
final localMusicProviderProvider = Provider<LocalMusicProvider>((ref) {
  return LocalMusicProvider(ref.watch(libraryRepositoryProvider));
});

/// Music Core 聚合层
///
/// Phase 2 只有 Local;Phase 4 起会把 NavidromeProvider 加进来。
final musicCoreProvider = Provider<MusicCore>((ref) {
  return MusicCore([
    ref.watch(localMusicProviderProvider),
  ]);
});

/// 流式订阅:所有歌(UI 主列表用)
final allSongsStreamProvider = StreamProvider<List<SongWithSource>>((ref) {
  return ref.watch(localMusicProviderProvider).watchAll();
});

/// 流式订阅:所有专辑
final allAlbumsStreamProvider = StreamProvider<List<AlbumRow>>((ref) {
  return ref.watch(localMusicProviderProvider).watchAlbums();
});

/// 流式订阅:所有艺人
final allArtistsStreamProvider = StreamProvider<List<ArtistRow>>((ref) {
  return ref.watch(localMusicProviderProvider).watchArtists();
});

/// 一次性库统计
final libraryStatsProvider = FutureProvider<LibraryStats>((ref) {
  return ref.watch(libraryRepositoryProvider).stats();
});

/// 当前扫描状态
sealed class ScanState {
  const ScanState();
}

class ScanIdle extends ScanState {
  const ScanIdle();
}

class ScanRunning extends ScanState {
  const ScanRunning();
}

class ScanSuccess extends ScanState {
  const ScanSuccess(this.importedCount, {this.lastScanAt});
  final int importedCount;
  final DateTime? lastScanAt;
}

class ScanFailed extends ScanState {
  const ScanFailed(this.message);
  final String message;
}

class ScanPermissionDenied extends ScanState {
  const ScanPermissionDenied();
}

/// 扫描动作的 Notifier(UI 调 [LocalLibraryScanner.scan] 触发)
class LocalLibraryScanner extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanIdle();

  /// 触发一次扫描
  Future<void> scan() async {
    state = const ScanRunning();
    try {
      final count = await ref.read(localMusicProviderProvider).refresh();
      state = ScanSuccess(count, lastScanAt: DateTime.now());
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('permission')) {
        state = const ScanPermissionDenied();
      } else {
        state = ScanFailed(msg);
      }
    }
  }
}

final localLibraryScannerProvider =
    NotifierProvider<LocalLibraryScanner, ScanState>(LocalLibraryScanner.new);
