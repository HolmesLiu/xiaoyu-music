import '../../database/app_database.dart';
import '../../database/library_repository.dart';

/// 音乐源抽象(02 §5)。
///
/// 所有音乐源(Local / NAS / Navidrome / Luoxue)必须实现这个接口。
/// Music Core 通过这个接口聚合各源的结果(去重、合并、排序)。
abstract class MusicProvider {
  /// Provider 唯一 ID,例如 "local" / "nas-smb-1" / "navidrome-main"
  String get id;

  /// Provider 类型,见 [MusicSourceType]
  MusicSourceType get type;

  /// Provider 显示名(用户在设置里看到的)
  String get displayName;

  /// Provider 是否已配置/可用(Local 总是 true;Navidrome 需登录;NAS 需挂载)
  Future<bool> isAvailable();

  /// 全文搜索(各源内部模糊匹配 title / artist / album)
  /// 返回 UI 层用的 [SongWithSource] 列表
  Future<List<SongWithSource>> search(String query, {int limit = 200});

  /// 拿一首歌(全源去重后唯一)
  Future<SongWithSource?> getSong(int songId);

  /// 拿一张专辑
  Future<AlbumRow?> getAlbum(int albumId);

  /// 拿一个艺人
  Future<ArtistRow?> getArtist(int artistId);

  /// 触发一次刷新(全量或增量,各源自行决定)
  /// 返回本次新增/更新的歌曲数
  Future<int> refresh();
}

/// Provider 来源类型(02 §7 Source.sourceType 的枚举)
enum MusicSourceType {
  local,
  nas,
  navidrome,
  luoxue,
}

extension MusicSourceTypeName on MusicSourceType {
  /// 数据库存储名(必须跟 Sources.sourceType 字段一致)
  String get dbName => switch (this) {
        MusicSourceType.local => 'LOCAL',
        MusicSourceType.nas => 'NAS',
        MusicSourceType.navidrome => 'NAVIDROME',
        MusicSourceType.luoxue => 'LUOXUE',
      };

  String get displayName => switch (this) {
        MusicSourceType.local => '本地',
        MusicSourceType.nas => 'NAS',
        MusicSourceType.navidrome => 'Navidrome',
        MusicSourceType.luoxue => '落雪',
      };
}
