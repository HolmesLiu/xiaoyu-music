import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/logging/app_logger.dart';

part 'app_database.g.dart';

// =============================================================================
// Phase 2 核心表
// =============================================================================

/// 歌曲主表 — 描述"一首歌"的抽象。
///
/// `id` 是本地数据库主键;`remoteId` 是 Navidrome/SMB 那边给这首歌的 id;
/// 同一首歌在多源都存在时,**Song 只存一份,Sources 表存多源**。
@DataClassName('SongRow')
class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ---- 基础信息 ----
  TextColumn get title => text().withLength(min: 1, max: 512)();
  TextColumn get artist => text().withLength(max: 512).withDefault(const Constant(''))();
  TextColumn get album => text().withLength(max: 512).withDefault(const Constant(''))();
  TextColumn get albumArtist => text().nullable()();
  IntColumn get trackNumber => integer().withDefault(const Constant(0))();
  IntColumn get discNumber => integer().withDefault(const Constant(0))();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  // ---- 媒体属性 ----
  TextColumn get mimeType => text().nullable()();
  IntColumn get bitrate => integer().nullable()();
  IntColumn get sampleRate => integer().nullable()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get contentHash => text().nullable()(); // Phase 8: 用于同步去重

  // ---- 元数据 ----
  TextColumn get lyrics => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateModified => dateTime().nullable()();

  // ---- 跨源去重用 fingerprint ----
  // acoustId / chromaprint 等(Phase 8 真正用,Phase 2 先留字段)
  TextColumn get acousticId => text().nullable()();
}

/// 专辑表。
@DataClassName('AlbumRow')
class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 512)();
  TextColumn get artist => text().withLength(max: 512).withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
}

/// 艺人表。
@DataClassName('ArtistRow')
class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 512)();
  IntColumn get albumCount => integer().withDefault(const Constant(0))();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  TextColumn get avatarPath => text().nullable()();
}

/// 一首歌在某个音乐源的具体位置。
///
/// 设计核心:同一首 Song 可以在 Local / NAS / Navidrome / Luoxue 同时存在,
/// 每条 Source 描述其中一份。`sourceType` 标识来源,`location` 是
/// Local/NAS 用的文件路径或 Navidrome 用的 stream URL 或 Luoxue 用的临时路径。
@DataClassName('SourceRow')
class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId =>
      integer().references(Songs, #id, onDelete: KeyAction.cascade)();

  /// LOCAL / NAS / NAVIDROME / LUOXUE
  TextColumn get sourceType => text().withLength(min: 1, max: 16)();

  /// 物理路径(Local/NAS)或 stream URL(Navidrome)或临时文件路径(Luoxue)
  TextColumn get location => text().withLength(min: 1, max: 1024)();

  /// 远端 id(Navidrome songId / Luoxue 资源 id);Local/NAS 为 null
  TextColumn get remoteId => text().nullable()();

  /// 文件 sha256,Phase 8 同步去重用
  TextColumn get fileHash => text().nullable()();

  /// 文件最后修改时间(用于增量扫描)
  DateTimeColumn get fileModifiedAt => dateTime().nullable()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();

  /// 优先级(LOCAL=0, NAS=10, NAVIDROME=20, LUOXUE=30,数字越小越高)
  /// Phase 4 接入 Navidrome 后实际用
  IntColumn get priority => integer().withDefault(const Constant(0))();

  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {songId, sourceType, location},
      ];
}

/// 播放历史。
@DataClassName('PlaybackRow')
class Playbacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId =>
      integer().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get playCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastPlayTime => dateTime().withDefault(currentDateAndTime)();
}

/// 元数据表 — 存 schema version、上次同步时间、扫描游标等。
@DataClassName('AppMetaRow')
class AppMetas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 64).unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Songs, Albums, Artists, Sources, Playbacks, AppMetas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: _dbFileName));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          AppLogger.i(_tag, 'Database created (schemaVersion=$schemaVersion)');
          await m.createAll();
          await into(appMetas).insert(
            AppMetasCompanion.insert(
              key: 'schema_version',
              value: schemaVersion.toString(),
              updatedAt: DateTime.now(),
            ),
          );
        },
        onUpgrade: (m, from, to) async {
          AppLogger.i(_tag, 'Database upgrading from $from to $to');
          // V1→V2: 从单一 AppMetas 占位表升级到完整 6 表
          if (from < 2) {
            await m.createTable(songs);
            await m.createTable(albums);
            await m.createTable(artists);
            await m.createTable(sources);
            await m.createTable(playbacks);
          }
        },
      );

  /// 元数据读写
  Future<String?> getMeta(String key) async {
    final row = await (select(appMetas)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) async {
    await into(appMetas).insertOnConflictUpdate(
      AppMetasCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  static const String _dbFileName = 'xiaoyu_music';
  static const String _tag = 'AppDatabase';

  static AppDatabase? _instance;

  /// 应用启动时调用一次,返回全局单例。
  static AppDatabase bootstrap() {
    _instance ??= AppDatabase();
    AppLogger.i(_tag, 'Bootstrap done (singleton ready)');
    return _instance!;
  }

  /// 全局单例读取器(必须先调 [bootstrap])。
  static AppDatabase get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'AppDatabase not initialized; call AppDatabase.bootstrap() first',
      );
    }
    return i;
  }
}
