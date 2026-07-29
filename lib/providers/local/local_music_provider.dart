import 'dart:async';

import 'package:on_audio_query/on_audio_query.dart';

import '../../core/logging/app_logger.dart';
import '../../database/app_database.dart';
import '../../database/library_repository.dart';
import '../base/music_provider.dart';

/// 本地音乐 Provider — 02 §5 四大 Provider 之一。
///
/// 职责:
/// 1. 用 [OnAudioQuery] 扫 Android MediaStore 的本地音频
/// 2. 把结果 upsert 到本地 [LibraryRepository](Song + Source)
/// 3. 实现 [MusicProvider] 的 search / getSong / getAlbum / getArtist
///
/// 平台说明:
/// - V0.2 (Phase 2) 只支持 Android,iOS 用 on_audio_query 走 Apple Music 库
///   但本仓库 V0.x 主跑 Android,iOS 在 Phase 10 优化
class LocalMusicProvider implements MusicProvider {
  LocalMusicProvider(this._repo, [OnAudioQuery? audioQuery])
      : _audioQuery = audioQuery ?? OnAudioQuery();

  final LibraryRepository _repo;
  final OnAudioQuery _audioQuery;
  static const String _tag = 'LocalMusicProvider';

  @override
  String get id => 'local';

  @override
  MusicSourceType get type => MusicSourceType.local;

  @override
  String get displayName => '本地音乐';

  @override
  Future<bool> isAvailable() async {
    // Local provider 在 Android 8+ 上始终可用(权限在 UI 层申请)
    return true;
  }

  // ============================ 扫描 ============================

  /// 触发一次完整扫描(用户进入本地库页或下拉刷新时调用)。
  ///
  /// 行为:
  /// 1. 请求 READ_MEDIA_AUDIO 权限
  /// 2. 清空旧的 LOCAL Source(孤儿 song 由 repository.clearLocal 一起清)
  /// 3. 调 [OnAudioQuery.querySongs] 拿所有歌曲
  /// 4. 过滤:duration > 10s(去掉误识别的铃声/通知)
  /// 5. 逐首 upsert 到数据库
  ///
  /// @return 本次扫到的歌曲数
  @override
  Future<int> refresh() async {
    AppLogger.i(_tag, '========== scan start ==========');

    // 1) 权限(Android 13+ READ_MEDIA_AUDIO,12- READ_EXTERNAL_STORAGE)
    final granted = await _audioQuery.checkAndRequest(
      retryRequest: true,
    );
    if (!granted) {
      AppLogger.w(_tag, 'Permission denied — skip scan');
      throw const _PermissionDenied();
    }
    AppLogger.i(_tag, 'Permission granted');

    // 2) 清旧
    await _repo.clearLocal();

    // 3) 查
    final List<SongModel> songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    AppLogger.i(_tag, 'MediaStore returned ${songs.length} songs');

    // 4) 过滤 + 5) 写入
    var imported = 0;
    var skipped = 0;
    for (final s in songs) {
      // 过滤:duration < 10s 的当铃声处理,跳过
      if ((s.duration ?? 0) < 10 * 1000) {
        skipped++;
        continue;
      }
      try {
        await _repo.upsertSongWithLocalSource(
          title: s.title.isEmpty
              ? (s.displayName.isEmpty ? '(unknown)' : s.displayName)
              : s.title,
          artist: s.artist ?? '(unknown)',
          album: s.album ?? '(unknown)',
          durationMs: s.duration ?? 0,
          mimeType: '', // on_audio_query 不直接给 mime,后续从 URI 推
          sizeBytes: 0, // on_audio_query 也不给 size
          location: s.uri ?? s.data,
          year: 0,
        );
        imported++;
      } catch (e, st) {
        AppLogger.e(_tag, 'Failed to import ${s.title}', error: e, stackTrace: st);
      }
    }
    AppLogger.i(_tag, '========== scan done: $imported imported, $skipped skipped ==========');
    return imported;
  }

  // ============================ 查询 ============================

  @override
  Future<List<SongWithSource>> search(String query, {int limit = 200}) async {
    final all = await _repo.getAllSongs();
    if (query.isEmpty) return all.take(limit).toList();
    final q = query.toLowerCase();
    return all
        .where((sws) =>
            sws.title.toLowerCase().contains(q) ||
            sws.artist.toLowerCase().contains(q) ||
            sws.album.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  @override
  Future<SongWithSource?> getSong(int songId) async {
    final all = await _repo.getAllSongs();
    for (final sws in all) {
      if (sws.id == songId) return sws;
    }
    return null;
  }

  @override
  Future<AlbumRow?> getAlbum(int albumId) async {
    final db = AppDatabase.instance;
    return (db.select(db.albums)..where((a) => a.id.equals(albumId))).getSingleOrNull();
  }

  @override
  Future<ArtistRow?> getArtist(int artistId) async {
    final db = AppDatabase.instance;
    return (db.select(db.artists)..where((a) => a.id.equals(artistId))).getSingleOrNull();
  }

  // ============================ 流式订阅(UI 用) ============================

  /// 订阅本地库歌曲变化(扫描完后 UI 自动更新)
  Stream<List<SongWithSource>> watchAll() => _repo.watchAllSongs();

  /// 订阅专辑列表
  Stream<List<AlbumRow>> watchAlbums() => _repo.watchAlbums();

  /// 订阅艺人列表
  Stream<List<ArtistRow>> watchArtists() => _repo.watchArtists();
}

class _PermissionDenied implements Exception {
  const _PermissionDenied();
  @override
  String toString() => 'LocalMusicProvider: permission denied';
}
