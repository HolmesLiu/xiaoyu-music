# 小雨音乐 (Xiaoyu Music) — 需求文档

> 版本: v0.2 · 日期: 2026-07-28

## 一、一句话定位

**小雨音乐 = 最好的 Navidrome 中文客户端,自带落雪"自定义源"下载能力,搜索到的资源可以一键入库到你的 Navidrome。**

### 用户场景(从用户原话总结)
> "可以先理解为 Navidrome 的客户端项目,现在确实没有一个好用的 Navidrome 客户端,尤其是中文版的。在该客户端基础上增加一个音乐搜索下载的功能,下载的音乐能够直接传到对应 Navidrome 就最好了。"

### 三个核心闭环
```
┌─────────────────────────────────────────────────┐
│  ① 本地音乐  ←→ ② Navidrome 远程库  ←→  ③ 落雪源下载 │
│        ↑                                            │
│        └────────── 下载自动入 Navidrome ─────────┘  │
└─────────────────────────────────────────────────┘
```

## 二、差异化对比

| 维度 | 落雪 lx-music | 国外 Navidrome 客户端 (Substreamer/Symfonium) | **小雨音乐** |
|---|---|---|---|
| 中文 | ✅ | ❌ | ✅ |
| Navidrome 客户端 | ❌(需手动配置) | ✅(英文,付费) | ✅(中文,免费) |
| 自定义源下载 | ✅(核心) | ❌ | ✅(核心) |
| 本地音乐管理 | 弱 | ✅ | ✅ |
| 下载→Navidrome 同步 | ❌ | ❌ | ✅(核心差异化) |
| 跨平台(规划) | 桌面+安卓 | 安卓 | 安卓+iOS+桌面 |
| 价格 | 免费 | 付费 | 免费 |

## 三、功能范围

### V1.0 — MVP(8-10 周)

#### 核心:播放
- [ ] 播放控制(播/暂/上下首/进度/音量/倍速 0.5x-2x)
- [ ] MediaSession 后台播放 + 通知栏 + 锁屏控制
- [ ] 音频焦点(来电/导航自动暂停恢复)
- [ ] 耳机线控 + 蓝牙按键
- [ ] 耳机拔出暂停
- [ ] LRC 歌词同步
- [ ] 专辑封面(内嵌 + 网络缓存)

#### 音乐来源
- [ ] **本地音乐**:MediaStore 扫描,ID3 标签解析
- [ ] **Navidrome(Subsonic API)**:
  - 登录(URL + 用户名 + 密码,支持 Token)
  - 浏览库:艺术家/专辑/歌曲/歌单
  - 流式播放(通过 Navidrome stream API)
  - 远程歌单同步
  - 收藏双向同步

#### 落雪"自定义源"集成
- [ ] 内置 QuickJS 引擎,执行 `.js` 音源脚本
- [ ] 内置默认源(社区维护的开源源,可空)
- [ ] 支持导入本地 `.js` 源文件
- [ ] 支持在线导入(URL 拉取)
- [ ] 多源管理:启用/禁用/优先级
- [ ] 搜索 → 多源结果聚合
- [ ] 在线播放(走源返回的 URL,流式)
- [ ] 歌词、封面(走源接口)

#### 列表 & 收藏
- [ ] 播放队列(当前 / 历史)
- [ ] 用户自建歌单
- [ ] 收藏(单首 / 专辑 / 整张)
- [ ] 最近播放 + 最常播放
- [ ] 歌单本地 + Navidrome 双向同步

#### 基础体验
- [ ] **主题系统**(详见第十一节):
  - **V1.0 范围**:1 套标准界面(Material You 默认),把功能闭环跑通
  - **接口预留**:`AppTheme` 数据模型 + `ThemeRepository` + `LocalAppTheme` + 颜色/圆角/字体的工程纪律
  - 设置页保留"主题"入口(暂只 1 项,UI 占位)
- [ ] 睡眠定时
- [ ] 5 段均衡器 + 预设(流行/摇滚/古典/爵士/电子)
- [ ] 倍速播放

### V1.1 — 核心差异化:下载→入 Navidrome(3-4 周)

- [ ] **下载管理**:队列、进度、断点续传
- [ ] **音质选择**:128k / 320k / FLAC / Hi-Res(按源能力)
- [ ] **本地入库**:下载到本地目录,自动 MediaStore 扫描
- [ ] **Navidrome 自动同步**:
  - 配置 Navidrome 音乐目录(本地路径)
  - 或通过 **SMB / WebDAV / SFTP** 协议上传到远程 Navidrome 服务器
  - 同步完成后调用 Navidrome `startScan` API
  - 显示同步状态(待传 / 上传中 / 已入库)
- [ ] **批量入库**:支持批量下载一批歌曲后一次入库

### V1.2 — 体验增强(2-3 周)

- [ ] **桌面歌词**(悬浮窗,可拖拽)
- [ ] 启动器 Widget(桌面小组件)
- [ ] 智能推荐(基于收听历史,本地计算)
- [ ] 播放统计(总时长 / 听歌排行)
- [ ] 备份与恢复(本地数据库)
- [ ] 应用锁(可选)

### 远期(跨平台)
- **iOS 版**:Swift + SwiftUI,共享 Subsonic API client 逻辑
- **桌面版**:Compose Multiplatform(macOS / Windows / Linux)
- **CarPlay / Android Auto**:车载支持
- **Wear OS**:手表控制

## 四、非功能性需求

| 项目 | 要求 |
|---|---|
| 启动时间 | 冷启动 < 1.5s |
| 内存占用 | 空闲 < 150MB,播放时 < 250MB |
| 兼容版本 | Android 8.0 (API 26) — 目标 Android 15 (API 35) |
| 包体积 | < 25MB(JS 引擎 + 框架 + 基础 UI,不含音源) |
| 离线能力 | 本地库 100% 离线;Navidrome 远程库断网提示;落雪源需要联网 |
| 隐私 | 不收集任何用户数据,无统计 SDK,无广告 |
| 权限最小化 | 存储 / 通知 / 网络 / 悬浮窗(可选) |
| 协议 | Apache 2.0(参考落雪,补一份应用层协议) |

## 五、技术选型(再次确认)

### Android 端

| 模块 | 选型 | 理由 |
|---|---|---|
| 语言 | **Kotlin 2.0+** | Android 官方 |
| UI | **Jetpack Compose + Material 3** | Material You 原生,动态取色一行代码 |
| 媒体 | **AndroidX Media3 (ExoPlayer)** | 业界标杆,锁屏/通知栏一体化 |
| 架构 | **MVI + Clean Architecture** | use case 复用,易测试 |
| DI | **Hilt** | 官方 |
| 网络 | **Retrofit + OkHttp + kotlinx.serialization** | 稳定 |
| 数据库 | **Room** | 本地歌单/播放记录/源配置 |
| 图片 | **Coil 3** | Compose 友好 |
| 异步 | **Kotlin Coroutines + Flow** | 官方 |
| 导航 | **Navigation Compose** | 类型安全 |
| 后台播放 | **MediaSessionService** | 锁屏/通知/控制 |
| **JS 引擎** | **QuickJS (QuickJS-Android 绑定)** | 落雪源直接执行,小(~700KB) |
| **文件传输** | **SMB: jcifs-ng, WebDAV: sardine, SFTP: sshd-android** | 远程 Navidrome 同步 |
| 桌面歌词 | **SYSTEM_ALERT_WINDOW + Compose** | 悬浮窗 |

### 远期
- iOS:Swift + SwiftUI,KMP 共享 Subsonic client
- 桌面:Compose Multiplatform

## 六、模块结构

```
xiaoyu-music/
├── app/                          # Application 入口
├── core/
│   ├── player/                   # Media3 封装、播放服务
│   ├── network/                  # OkHttp / Retrofit
│   ├── database/                 # Room
│   ├── ui/                       # Compose 主题、通用组件
│   ├── domain/                   # 业务模型、UseCase
│   ├── js-engine/                # QuickJS 集成,落雪源协议
│   ├── transfer/                 # SMB / WebDAV / SFTP 客户端
│   └── common/                   # 工具
├── data/
│   ├── local/                    # MediaStore 扫描
│   ├── remote-navidrome/         # Subsonic API
│   ├── remote-source/            # 落雪源调用(走 JS 引擎)
│   ├── upload/                   # 远程 Navidrome 同步
│   └── repository/               # 仓储
├── feature/
│   ├── home/                     # 首页
│   ├── player/                   # 全屏播放
│   ├── library-local/            # 本地音乐
│   ├── library-navidrome/        # Navidrome 远程库
│   ├── search/                   # 多源聚合搜索
│   ├── download/                 # 下载管理
│   ├── source-manager/           # 落雪源管理
│   ├── playlist/                 # 歌单
│   ├── lyrics/                   # 歌词 + 桌面歌词
│   ├── equalizer/                # 均衡器
│   └── settings/                 # 设置
├── plugin/
│   └── default-sources/          # 内置的开源音源(可空)
└── docs/
    ├── requirements.md           # 本文件
    ├── architecture.md           # 架构设计
    └── api/
        ├── subsonic.md           # Subsonic API 客户端说明
        └── lx-source.md          # 落雪自定义源协议(JS 端接口规范)
```

## 七、关键设计点

### 1. 落雪"自定义源"协议(JS 端)
落雪没正式公开文档,需要从源码里逆向出 `musicSdk` 的接口契约。社区源都遵循一套约定:

```javascript
// 约定俗成的源模块结构
module.exports = {
  // 平台标识
  __name: 'my-source',
  // 搜索
  search(keyword, page, limit) { return [{ id, name, singer, album, source }] },
  // 歌曲详情
  song(id) { return { id, name, singer, album, source, lyric, pic, url } },
  // 封面
  pic(id) { return url },
  // 歌词
  lyric(id) { return lrcText },
  // MP3/FLAC URL
  url(id, br) { return url },
}
```

App 端需要按这个契约来调用 JS 函数(通过 QuickJS 桥接)。

### 2. "下载→入 Navidrome" 流程
```
用户在落雪源搜到歌 → 点下载
        ↓
选择音质(128/320/FLAC)
        ↓
下载到本地 download 目录
        ↓
检测 Navidrome 配置:
  ├─ 本地 music 目录(用户手机/NAS 共享)→ cp/mv
  ├─ 远程 WebDAV/SMB → upload
  └─ 远程 SFTP → upload
        ↓
调用 Navidrome Subsonic API: startScan
        ↓
歌曲出现在 Navidrome 库
        ↓
App 远程库自动刷新
```

### 3. 数据模型统一
为避免"本地歌曲"和"Navidrome 歌曲"和"落雪源歌曲"三套体系混乱,统一一个抽象:
```kotlin
data class Track(
  val id: String,                    // 唯一 ID(源 + 原始 id 拼接)
  val source: TrackSource,           // 来源:LOCAL / NAVIDROME / LX_SOURCE
  val title: String,
  val artist: String,
  val album: String,
  val durationMs: Long,
  val coverUrl: String?,
  val playUrl: String,               // 媒体 URL(MediaStore URI / Navidrome stream / 源 URL)
  val lyricUrl: String? = null,
  val bitrate: Int? = null,
  val suffix: String? = null,        // mp3/flac/ogg...
)
```

## 八、版本路线图(更新)

| 版本 | 内容 | 周期 |
|---|---|---|
| **V0.5** | 脚手架、Compose 主题、Media3 基础、本地音乐 | 2-3 周 |
| **V0.8** | Navidrome Subsonic 客户端(流式播放、远程库) | 3 周 |
| **V1.0** | 落雪源集成(QuickJS)、多源搜索、播放队列、歌词、EQ + 主题接口预留(1 套标准 + 抽象层) | 3-4 周 |
| **V1.1** | **下载管理 + 远程 Navidrome 自动同步(核心差异化)** | 3-4 周 |
| **V1.2** | 桌面歌词、Widget、推荐 | 2-3 周 |
| **V2.0** | iOS 版(共享 API client 层) | 6-8 周 |
| **V2.1** | 桌面版(macOS 优先) | 4-6 周 |

## 九、已确定 & 待拍板

### ✅ 已确定
1. **项目名**:小雨音乐
2. **包名**:`com.xiaoyu.music`
3. **账号体系**:不做
4. **图标**:先占位
5. **JS 引擎方案**:**QuickJS**(路线 A,直接复用落雪 .js 源)
6. **音乐搜索/下载对齐落雪**:加新源 = 导入 .js 文件即可使用
7. **Navidrome 同步方式**:本地路径 + **WebDAV**(V1.1)
8. **应用层协议**:Apache 2.0 + 补充条款
9. **版本维护**:GitHub,**每次变动都要做版本管理**(规范见 [version-management.md](./version-management.md))

### ⚠️ 待你拍板
1. **GitHub 仓库信息**:
   - 用户名 / 组织名:**`HolmesLiu`**
   - 仓库名:**`xiaoyu-music`**
   - 公开 / 私有:**公开**(已创建)
2. **CI**:用 GitHub Actions 吗?(我建议用,免费额度够)**✅ 已配置 release-please**
3. **CarPlay / Android Auto**:远期,要不要进 V1?
4. **主题系统范围**:**已定**——V1.0 只做 1 套标准 + 接口预留,多主题推后到 V2.0+

## 十一、UI 主题化设计

### 设计原则
**先做正确,后做多样。** V1.0 只做 1 套标准界面(Material You 默认),把播放 / 扫描 / 歌词 / EQ / Navidrome / 下载等所有功能跑通。**但主题接口必须预留到位**——未来做多套主题、社区主题包时,业务代码零改动就能套新主题。

### V1.0 范围
- ✅ **1 套标准主题**:Material You 默认(Material 3 + 动态取色,Android 12+ 走 `dynamicColorScheme`,8.0-11 走静态 fallback)
- ✅ **接口预留**(关键!):
  - `AppTheme` 数据模型抽象
  - `ThemeRepository` / Hilt 注入
  - `LocalAppTheme` CompositionLocal 全局访问
  - 颜色 / 圆角 / 字体**全部走 `MaterialTheme.xxx`**,禁止硬编码
  - 设置页保留"主题"入口(暂只 1 项,UI 占位)
- ❌ **不做**(全部推后):
  - 多套内置主题变体
  - 用户自定义调色
  - 主题包协议(`.xiaoyu-theme`)
  - 主题商店
  - 主题包生态

### 核心数据模型(预留)
```kotlin
// 主题数据模型
data class AppTheme(
    val id: String,
    val name: String,
    val colorScheme: ColorScheme,    // Material 3 ColorScheme
    val shapes: Shapes,              // 圆角
    val typography: Typography,      // 字体
)

// 主题仓库(V1.0 只内置 1 套,但接口必须这样)
interface ThemeRepository {
    val current: StateFlow<AppTheme>
    val available: StateFlow<List<AppTheme>>  // V1.0 只有 1 项
    fun setTheme(id: String)
}

// 全局访问
val LocalAppTheme = staticCompositionLocalOf<AppTheme> { error("AppTheme not provided") }
```

### 主题切换流程(预留)
```
用户在设置选主题(暂只 1 项,UI 占位)
        ↓
ThemeRepository.setTheme(themeId)
        ↓
触发 StateFlow 更新
        ↓
根 Composable 重组,MaterialTheme 应用新色板
        ↓
所有子组件自动应用新主题(因为都通过 MaterialTheme.colorScheme 拿色)
        ↓
无需重启 Activity
```

### 工程纪律(强制执行,任何 PR 违规必须改)
- ❌ 禁止:`Color(0xFF1DB954)` 硬编码颜色
- ✅ 强制:`MaterialTheme.colorScheme.primary`
- ❌ 禁止:`RoundedCornerShape(16.dp)` 硬编码圆角
- ✅ 强制:`MaterialTheme.shapes.medium`
- ❌ 禁止:`fontSize = 14.sp` 硬编码字号
- ✅ 强制:`MaterialTheme.typography.bodyMedium`
- ❌ 禁止:`Modifier.padding(16.dp)` 硬编码间距
- ✅ 强制:通过 `LocalSpacing` 或 `MaterialTheme` 拿(预留接口)
- **Code Review 检查项**:每加一个新组件,色 / 圆角 / 字号 / 间距必须走主题

### 未来扩展(V1.0 完成后,功能跑通后再启动)
- V1.x 后期:加 2-3 套主题变体(浅色经典 / 深色经典 / 复古绿等),验证接口
- V2.0+:**主题包协议** `.xiaoyu-theme`(JSON 描述 + 可选资源 zip)+ 主题商店
- 远期:完全动态 UI(谨慎评估)

## 十、下一步

确认 V1 范围和技术选型后,启动 **V0.5 工程脚手架**:
1. 初始化 Gradle 多模块项目
2. 配置 Hilt + Compose + Material 3
3. 集成 Media3 + ExoPlayer
4. 实现本地音乐扫描(MVP 播放闭环)
