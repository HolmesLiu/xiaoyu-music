# 小雨音乐 — 构建指南

## 1. 通过 GitHub Actions 构建(推荐,无需本地环境)

所有 push / PR 到 `main` 分支都会自动触发构建,产物在 Actions Artifacts 里。

### 怎么下载 APK
1. 进入仓库页面 `https://github.com/HolmesLiu/xiaoyu-music`
2. 顶部点击 `Actions` 标签
3. 选择最近的 `Android Build` workflow run
4. 滚动到底部 `Artifacts` 区域
5. 下载 `app-debug` → 得到 debug APK

### Release 构建(tag 触发)
- 推送 tag 触发 release 构建(暂未配置签名,需要先在 GitHub Secrets 配置 `KEYSTORE_BASE64` 和 `KEYSTORE_PROPERTIES`)
- 详见 [签名配置](#4-签名配置可选)

## 2. 本地构建(可选)

### 环境要求
- **JDK 17**(`brew install --cask temurin@17` 或用 Android Studio 自带)
- **Android Studio Ladybug | 2024.2.1+**(自带 SDK 管理)
- **Android SDK Platform 35** + Build-Tools 35.0.0
- **Gradle 8.10**(项目自带 wrapper,无需单独装)

### 首次配置
```bash
# 1. 克隆
git clone https://github.com/HolmesLiu/xiaoyu-music.git
cd xiaoyu-music

# 2. 用 Android Studio 打开
#    Android Studio 会自动:
#    - 创建 local.properties(配置 SDK 路径)
#    - 下载 Gradle wrapper 依赖
#    - 同步项目

# 3. 命令行构建
./gradlew assembleDebug           # 构建 debug APK
./gradlew assembleRelease         # 构建 release APK
./gradlew testDebugUnitTest       # 跑单元测试
./gradlew lintDebug               # 跑 lint
```

### 常见问题
- **SDK 找不到**:在 `local.properties` 配 `sdk.dir=/path/to/Android/sdk`
- **Gradle 慢**:首次会下很多依赖,后续走 cache
- **构建失败**:先跑 `./gradlew --stacktrace assembleDebug` 看完整错误

## 3. 模块结构

```
xiaoyu-music/
├── app/                      # Application 入口
├── core/                     # 核心库
│   ├── common/               # 工具、扩展
│   ├── ui/                   # 主题、通用组件
│   ├── database/             # Room
│   └── player/               # Media3 封装
├── data/                     # 数据层
│   ├── local/                # MediaStore 扫描
│   └── repository/           # 仓储
└── feature/                  # 业务模块
    ├── home/                 # 首页
    ├── library-local/        # 本地音乐库
    ├── player/               # 播放页
    └── settings/             # 设置
```

## 4. 签名配置(可选,Release 用)

要构建可分发的 release APK,需要配置签名:

### 4.1 生成 keystore
```bash
keytool -genkey -v -keystore release.keystore -alias xiaoyu \
  -keyalg RSA -keysize 2048 -validity 10000
```

### 4.2 准备 keystore.properties
创建 `keystore.properties`:
```properties
storeFile=release.keystore
storePassword=your_store_password
keyAlias=xiaoyu
keyPassword=your_key_password
```

### 4.3 配置 GitHub Secrets
1. 把 `release.keystore` base64 编码:
   ```bash
   base64 -i release.keystore | tr -d '\n' > keystore.base64
   ```
2. 仓库 → Settings → Secrets and variables → Actions
3. 添加两个 Secret:
   - `KEYSTORE_BASE64`:`keystore.base64` 文件内容
   - `KEYSTORE_PROPERTIES`:`keystore.properties` 文件内容

CI 会自动解码 + 签名。

## 5. 版本管理

每次发版自动走 release-please:
- 提交时遵循 [Conventional Commits](./docs/version-management.md)
- `feat:` → 自动 minor 版本
- `fix:` → 自动 patch 版本
- push 到 main → release-please 自动开 PR
- merge PR → 自动 tag + GitHub Release
