import 'dart:async';

import '../database/library_repository.dart';
import 'base/music_provider.dart';

/// Music Core — 02 §4.1 核心抽象层。
///
/// 职责:
/// 1. 持有所有 [MusicProvider](Local / NAS / Navidrome / Luoxue)
/// 2. 统一入口:`search` / `refresh` / `getSong` / `getAlbum` / `getArtist`
/// 3. 跨源去重(基于 song metadata 指纹,Phase 8 接 contentHash;Phase 2 简化)
/// 4. 跨源合并:同一首 Song 在多源时,优先取 LOCAL → NAS → NAVIDROME → LUOXUE
class MusicCore {
  MusicCore(this._providers);

  final List<MusicProvider> _providers;

  /// 当前所有 provider(只读)
  List<MusicProvider> get providers => List.unmodifiable(_providers);

  /// 只有一个 Local provider 时,直接返回它(优化)
  MusicProvider? findProviderById(String id) {
    for (final p in _providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ============================ 跨源搜索 ============================

  /// 在所有可用 provider 上跑 search,合并去重结果。
  ///
  /// 合并规则(Phase 2 简化版):
  /// - 每个 provider 返回 [SongWithSource] 列表(已是 provider 内部去重过的)
  /// - 跨 provider 用 (title, artist, durationMs) 启发式去重
  /// - 优先级 LOCAL > NAS > NAVIDROME > LUOXUE(保留最高优先级的 source)
  Future<List<SongWithSource>> search(String query, {int limit = 200}) async {
    final availableProviders = <MusicProvider>[];
    for (final p in _providers) {
      if (await p.isAvailable()) availableProviders.add(p);
    }
    if (availableProviders.isEmpty) return const [];

    // 并行 search
    final results = await Future.wait(
      availableProviders.map((p) => p.search(query, limit: limit)),
    );

    // 合并去重
    final merged = <String, _MergedEntry>{};
    for (var i = 0; i < availableProviders.length; i++) {
      final priority = _priority(availableProviders[i].type);
      for (final sws in results[i]) {
        final key = _mergeKey(sws);
        final existing = merged[key];
        if (existing == null || priority < existing.priority) {
          merged[key] = _MergedEntry(song: sws, priority: priority);
        }
      }
    }
    final list = merged.values.map((e) => e.song).toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list.take(limit).toList();
  }

  /// 跨源拿一首歌
  Future<SongWithSource?> getSong(int songId) async {
    for (final p in _providers) {
      if (await p.isAvailable()) {
        final song = await p.getSong(songId);
        if (song != null) return song;
      }
    }
    return null;
  }

  /// 跨源刷一次(每个 provider 内部决定全量/增量)
  /// 返回 (providerId -> importedCount) 映射
  Future<Map<String, int>> refresh() async {
    final out = <String, int>{};
    for (final p in _providers) {
      if (await p.isAvailable()) {
        try {
          out[p.id] = await p.refresh();
        } catch (e) {
          out[p.id] = 0; // 失败记 0
        }
      } else {
        out[p.id] = 0;
      }
    }
    return out;
  }

  // ============================ 私有 helper ============================

  String _mergeKey(SongWithSource sws) {
    // Phase 2 简化:用 (lowercase title, lowercase artist, durationMs) 当指纹
    // Phase 8 改用 contentHash / acousticId
    final t = sws.title.toLowerCase().trim();
    final a = sws.artist.toLowerCase().trim();
    return '$t|$a|${sws.durationMs}';
  }

  int _priority(MusicSourceType t) => switch (t) {
        MusicSourceType.local => 0,
        MusicSourceType.nas => 10,
        MusicSourceType.navidrome => 20,
        MusicSourceType.luoxue => 30,
      };
}

class _MergedEntry {
  const _MergedEntry({required this.song, required this.priority});
  final SongWithSource song;
  final int priority;
}
