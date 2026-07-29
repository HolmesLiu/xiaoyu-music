import 'package:drift/drift.dart';

import '../core/logging/app_logger.dart';
import 'app_database.dart';

/// 库核心仓库 — 封装 Songs / Albums / Artists / Sources / Playbacks 的常用 CRUD。
///
/// 设计:
/// - 接受一个 [AppDatabase] 引用,允许替换(测试时用 `:memory:` 或 mock)
/// - 所有方法都是 `Future` / `Stream`,Riverpod provider 直接 wrap
/// - V0.2 (Phase 2) 只暴露"扫描写入 + 列表读取 + 简单删除",去重/搜索/分页 V0.3+ 扩展
class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;
  static const String _tag = 'LibraryRepository';

  // ============================ 读 ============================

  /// 订阅"所有歌 + 其默认 source"流(UI 主列表用)
  Stream<List<SongWithSource>> watchAllSongs() {
    final query = _db.select(_db.songs).join([
      innerJoin(
        _db.sources,
        _db.sources.songId.equalsExp(_db.songs.id),
      ),
    ]);
    // 排序:title asc,JOIN 后的 orderingTerm 写法
    return query.watch().map((rows) {
      final out = rows.map((row) {
        return SongWithSource(
          song: row.readTable(_db.songs),
          source: row.readTable(_db.sources),
        );
      }).toList();
      out.sort((a, b) => a.song.title.toLowerCase().compareTo(
            b.song.title.toLowerCase(),
          ));
      return out;
    });
  }

  /// 一次性快照(非流式)
  Future<List<SongWithSource>> getAllSongs() async {
    final rows = await (_db.select(_db.songs).join([
      innerJoin(
        _db.sources,
        _db.sources.songId.equalsExp(_db.songs.id),
      ),
    ])).get();
    final out = rows
        .map((row) => SongWithSource(
              song: row.readTable(_db.songs),
              source: row.readTable(_db.sources),
            ))
        .toList();
    out.sort((a, b) => a.song.title.toLowerCase().compareTo(
          b.song.title.toLowerCase(),
        ));
    return out;
  }

  /// 专辑列表
  Stream<List<AlbumRow>> watchAlbums() {
    return _db.select(_db.albums).watch();
  }

  /// 艺人列表
  Stream<List<ArtistRow>> watchArtists() {
    return _db.select(_db.artists).watch();
  }

  /// 库的统计
  Future<LibraryStats> stats() async {
    final songCountRow = await (_db.selectOnly(_db.songs)
          ..addColumns([_db.songs.id.count()]))
        .getSingle();
    final albumCountRow = await (_db.selectOnly(_db.albums)
          ..addColumns([_db.albums.id.count()]))
        .getSingle();
    final artistCountRow = await (_db.selectOnly(_db.artists)
          ..addColumns([_db.artists.id.count()]))
        .getSingle();
    final sourceCountRow = await (_db.selectOnly(_db.sources)
          ..addColumns([_db.sources.id.count()]))
        .getSingle();
    return LibraryStats(
      songCount: songCountRow.read(_db.songs.id.count()) ?? 0,
      albumCount: albumCountRow.read(_db.albums.id.count()) ?? 0,
      artistCount: artistCountRow.read(_db.artists.id.count()) ?? 0,
      sourceCount: sourceCountRow.read(_db.sources.id.count()) ?? 0,
    );
  }

  /// 库是否为空(用于判断是否需要提示用户扫描)
  Future<bool> isEmpty() async {
    final count = await (_db.selectOnly(_db.songs)
          ..addColumns([_db.songs.id.count()]))
        .getSingle();
    return (count.read(_db.songs.id.count()) ?? 0) == 0;
  }

  // ============================ 写 ============================

  /// 一首来自某 source 的扫描结果(由 LocalMusicProvider 调用)。
  ///
  /// 行为:
  /// 1. 找/创 Artist
  /// 2. 找/创 Album
  /// 3. 找/创 Song(去重键:title + artist + album + durationMs)
  /// 4. 找/创 Source(UNIQUE songId+sourceType+location)
  Future<int> upsertSongWithLocalSource({
    required String title,
    required String artist,
    required String album,
    required int durationMs,
    required String mimeType,
    required int sizeBytes,
    required String location,
    required int year,
  }) async {
    return _db.transaction(() async {
      // 1) Artist
      final artistName = artist.trim().isEmpty ? '(unknown)' : artist.trim();
      var artistRow = await (_db.select(_db.artists)
            ..where((a) => a.name.equals(artistName))
            ..limit(1))
          .getSingleOrNull();
      if (artistRow == null) {
        await _db.into(_db.artists).insert(
              ArtistsCompanion.insert(name: artistName),
            );
      }

      // 2) Album
      final albumName = album.trim().isEmpty ? '(unknown)' : album.trim();
      var albumRow = await (_db.select(_db.albums)
            ..where((a) => a.name.equals(albumName) & a.artist.equals(artistName))
            ..limit(1))
          .getSingleOrNull();
      if (albumRow == null) {
        await _db.into(_db.albums).insert(
              AlbumsCompanion.insert(
                name: albumName,
                artist: Value(artistName),
              ),
            );
      }

      // 3) Song — 用 select-then-insert 简化去重(Phase 2 暂不上 onConflict)
      var songRow = await (_db.select(_db.songs)
            ..where((s) =>
                s.title.equals(title) &
                s.artist.equals(artistName) &
                s.album.equals(albumName) &
                s.durationMs.equals(durationMs))
            ..limit(1))
          .getSingleOrNull();
      final songId = songRow?.id ??
          await _db.into(_db.songs).insert(
                SongsCompanion.insert(
                  title: title,
                  artist: Value(artistName),
                  album: Value(albumName),
                  durationMs: Value(durationMs),
                  mimeType: Value(mimeType.isEmpty ? null : mimeType),
                  sizeBytes: Value(sizeBytes),
                  year: Value(year == 0 ? null : year),
                  dateModified: Value(DateTime.now()),
                ),
              );

      // 4) Source(UNIQUE songId+sourceType+location → 已存在则忽略)
      final existingSource = await (_db.select(_db.sources)
            ..where((s) =>
                s.songId.equals(songId) &
                s.sourceType.equals('LOCAL') &
                s.location.equals(location))
            ..limit(1))
          .getSingleOrNull();
      if (existingSource == null) {
        await _db.into(_db.sources).insert(
              SourcesCompanion.insert(
                songId: songId,
                sourceType: 'LOCAL',
                location: location,
                fileSizeBytes: Value(sizeBytes),
                priority: const Value(0), // LOCAL 最高优先级
                dateAdded: Value(DateTime.now()),
              ),
            );
      }

      return songId;
    });
  }

  /// 清空所有 Local 源的歌(重新扫描前用)
  Future<int> clearLocal() async {
    return _db.transaction(() async {
      // 删 LOCAL 类型的 sources
      final deletedSources = await (_db.delete(_db.sources)
            ..where((s) => s.sourceType.equals('LOCAL')))
          .go();
      // 删孤儿 Song(没有任何 source 的)
      final orphanRows = await _db.customSelect(
        'SELECT id FROM songs WHERE id NOT IN (SELECT DISTINCT song_id FROM sources)',
        readsFrom: {_db.songs},
      ).get();
      for (final row in orphanRows) {
        await (_db.delete(_db.songs)..where((s) => s.id.equals(row.read<int>('id')))).go();
      }
      AppLogger.i(_tag, 'clearLocal: removed $deletedSources local sources, '
          '${orphanRows.length} orphan songs');
      return deletedSources;
    });
  }

  /// 全清(测试用,生产代码慎用)
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.sources).go();
      await _db.delete(_db.playbacks).go();
      await _db.delete(_db.songs).go();
      await _db.delete(_db.albums).go();
      await _db.delete(_db.artists).go();
    });
  }

  // ============================ 私有 helper ============================
}

/// 联合查询结果:一首 Song + 它的 Source。
class SongWithSource {
  const SongWithSource({required this.song, required this.source});
  final SongRow song;
  final SourceRow source;

  int get id => song.id;
  String get title => song.title;
  String get artist => song.artist;
  String get album => song.album;
  int get durationMs => song.durationMs;
  String? get coverPath => song.coverPath;
  String get location => source.location;
  String get sourceType => source.sourceType;
}

class LibraryStats {
  const LibraryStats({
    required this.songCount,
    required this.albumCount,
    required this.artistCount,
    required this.sourceCount,
  });
  final int songCount;
  final int albumCount;
  final int artistCount;
  final int sourceCount;
}
