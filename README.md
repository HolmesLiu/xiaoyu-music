# 小雨音乐 (Xiaoyu Music)

> **最好的 Navidrome 中文客户端,自带落雪"自定义源"下载能力,下载的资源可一键入库到你的 Navidrome。**

[![Status](https://img.shields.io/badge/status-v0.5%20WIP-yellow)]()
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%208.0%2B-green)]()

## 核心特性

- 🎵 **本地音乐** — MediaStore 扫描、ID3 解析、专辑封面提取
- 🌐 **Navidrome 客户端** — 完整支持 Subsonic API,流式播放、远程库浏览、收藏双向同步
- 📥 **落雪"自定义源"下载** — 内嵌 QuickJS 引擎,直接复用落雪 .js 源生态
- ☁️ **下载 → 自动入 Navidrome** — 核心差异化:搜索 → 下载 → 一键入个人音乐库
- 🎨 **Material You 主题** — 现代化动态取色 UI,深色模式原生支持
- 🎚️ **专业播放体验** — Media3 / ExoPlayer、LRC 歌词、5 段 EQ、睡眠定时

## 状态

🚧 **V0.5 脚手架阶段** — 尚无可用 APK,功能开发中

| 版本 | 内容 | 状态 |
|---|---|---|
| V0.5 | 工程脚手架、Compose、Media3、本地音乐 | 🔜 启动中 |
| V0.8 | Navidrome Subsonic 客户端 | 📅 待办 |
| V1.0 | 落雪源集成、多源搜索、播放队列、歌词、EQ | 📅 待办 |
| V1.1 | 下载管理 + 远程 Navidrome 自动同步 | 📅 待办 |
| V1.2 | 桌面歌词、Widget、推荐 | 📅 待办 |

## 文档

- 📋 [需求文档](./docs/requirements.md)
- 🏷️ [版本管理规范](./docs/version-management.md)
- 🏗️ [架构设计](./docs/architecture.md)(待写)

## 致谢

本项目受以下开源项目启发:

- [lx-music-desktop](https://github.com/lyswhut/lx-music-desktop) — 落雪音乐桌面端
- [lx-music-mobile](https://github.com/lyswhut/lx-music-mobile) — 落雪音乐移动端
- [Navidrome](https://github.com/navidrome/navidrome) — 自托管音乐服务器

## 协议

基于 [Apache License 2.0](./LICENSE) + 补充条款授权,详见 [NOTICE](./NOTICE)。
