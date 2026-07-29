import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/logging/app_logger.dart';

part 'app_database.g.dart';

/// 应用元数据表(Phase 1 占位,Phase 2 起逐步替换为 Song/Album/Artist/Source)。
///
/// 用途:
/// - 存 schema version 之外的客户端全局信息(比如"Navidrome 上次同步时间",
///   "数据库首次创建时间"等)
/// - Phase 1 至少要有一张表,Drift 不允许 `@DriftDatabase(tables: [])`
@DataClassName('AppMetaRow')
class AppMetas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 64).unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [AppMetas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: _dbFileName));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          AppLogger.i(_tag, 'Database created (schemaVersion=$schemaVersion)');
          await m.createAll();
          // 写入 schema 版本标记,后续 Phase 迁移时读
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
          // Phase 2 起会按 from/to 分支加迁移逻辑
        },
      );

  /// 读元数据
  Future<String?> getMeta(String key) async {
    final row = await (select(appMetas)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// 写元数据(upsert)
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

  /// 应用启动时调用一次(在 main() 里),返回全局单例。
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
