# 小雨音乐 — 版本管理规范

> 让每一次变动都"有迹可循、有版可循、有据可查"。

## 一、版本号规范(SemVer 2.0)

格式:**MAJOR.MINOR.PATCH**,例:`1.4.2`

| 位置 | 何时变更 | 示例 |
|---|---|---|
| **MAJOR** | 重大架构调整、不兼容的 API/数据格式变更 | `1.0.0` → `2.0.0` |
| **MINOR** | 新增功能、向下兼容 | `1.0.0` → `1.1.0` |
| **PATCH** | Bug 修复、小优化、文档/构建调整 | `1.0.0` → `1.0.1` |

**预发布版本**:`1.0.0-alpha.1` / `1.0.0-beta.2` / `1.0.0-rc.1`

**Android 端额外规则**:
- `versionName`(用户可见,字符串,如 `1.4.2-beta.1`)
- `versionCode`(内部递增,每次发版 `+1`,Play Store 上传用)

## 二、Commit 规范(Conventional Commits)

格式:
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 列表
| Type | 用途 | 是否触发版本 |
|---|---|---|
| `feat` | 新功能 | MINOR 升级 |
| `fix` | 修复 bug | PATCH 升级 |
| `perf` | 性能优化 | PATCH 升级 |
| `refactor` | 重构(无功能变化) | PATCH 升级 |
| `docs` | 文档变更 | 不触发 |
| `style` | 格式调整(空格、分号等) | 不触发 |
| `test` | 测试相关 | 不触发 |
| `build` | 构建系统、依赖变更 | 不触发 |
| `ci` | CI/CD 配置 | 不触发 |
| `chore` | 杂项(配置、脚本) | 不触发 |
| `revert` | 回滚 | 与被回滚的 commit 一致 |

### Scope 建议
`player` / `navidrome` / `source` / `download` / `ui` / `lyrics` / `eq` / `deps` / `docs` / `release`

### 示例
```bash
feat(player): 支持自定义倍速档位 0.25x 步进
fix(navidrome): 修复 Token 登录后立即失效的问题
docs: 补充 WebDAV 配置示例
chore(deps): bump media3 to 1.4.1
```

## 三、分支策略

简化版 Git Flow,主分支两条:

```
main (稳定,每个 commit 对应一个发布版本)
  ↑
  └── feat/xxx → 完成后 PR 合入 main
  └── fix/xxx → 紧急修复直合 main
```

### 分支命名
- `feat/<scope>-<short-desc>`:`feat/player-loop-mode`
- `fix/<scope>-<short-desc>`:`fix/source-crash-on-empty`
- `docs/<short-desc>`:`docs/readme-screenshots`
- `chore/<short-desc>`:`chore/bump-kotlin-2.0`

### 流程
1. 从 `main` 切功能分支
2. 开发 + commit(遵循 Conventional Commits)
3. 本地自测通过后,**必须重新基于最新 main rebase**(避免脏历史)
4. 推送到远端,创建 PR
5. PR 通过 review(自审或协作者)后,合入 main
6. 在 main 上打 tag + 生成 release

## 四、Tag & Release 流程

### Tag 命名
- 正式版:`v1.0.0`、`v1.1.0`
- 预发布:`v1.0.0-alpha.1`、`v1.0.0-beta.1`

### 操作流程
```bash
# 1. 切到 main,确保最新
git checkout main && git pull

# 2. 触发自动发布(release-please 会自动从 commit 历史生成 CHANGELOG + tag + release notes)
# 或者手动:
npm run release     # 如果用 standard-version
# 或
npx release-please  # 如果用 release-please
```

### Release 包含的内容
1. Git tag
2. GitHub Release(标题、说明)
3. APK 安装包(签名后的)
4. 资源(更新日志截图、特性截图)

## 五、CHANGELOG 自动化

**工具选型**:`release-please`(Google 出品,基于 Conventional Commits)

### 好处
- 自动从 commit 历史生成 CHANGELOG
- 自动判断 bump 类型(feat → minor / fix → patch)
- 自动创建 PR,merge 后自动打 tag + Release
- 配置一次,持续生效

### 配置位置
- `.github/release-please-config.json`
- `.release-please-manifest.json`

## 六、每次发版的标准动作清单

> "每次变动修改都要做对应的版本管理" = 每次发版都走这个清单。

- [ ] 1. 本地所有改动 commit 完(遵循 Conventional Commits)
- [ ] 2. `main` 分支 rebase 最新
- [ ] 3. 跑通全部单元测试 + UI 测试
- [ ] 4. 更新 `versionName` 和 `versionCode`(在 `app/build.gradle.kts`)
- [ ] 5. 触发 release-please → 自动生成 CHANGELOG PR
- [ ] 6. 检查 CHANGELOG 内容是否准确
- [ ] 7. merge CHANGELOG PR → 自动打 tag + Release
- [ ] 8. 构建签名 APK 上传
- [ ] 9. 在 Release 页面写 Release Notes(用户可读)
- [ ] 10. 在 README / 文档里更新版本号

## 七、紧急修复 Hotfix 流程

发现生产环境的 P0 bug:
```bash
# 从最新 tag 切 hotfix 分支
git checkout v1.0.0 && git checkout -b hotfix/v1.0.1-crash

# 修复 + commit(fix: ...)
git commit -m "fix(player): 修复播放服务在 Android 14 上的崩溃"

# 推 + 合入 main
git push -u origin hotfix/v1.0.1-crash
# 走 PR 流程,合入 main

# release-please 会自动检测到 fix: → 创建 v1.0.1 PR
```

## 八、未来 iOS / 桌面版版本对齐

后续 iOS / 桌面版会**共享同一套 SemVer**:
- 跨端共有的功能(bug 修复、API 协议)→ 同步升级
- 端独有功能(只影响 Android 的)→ 也走 SemVer,版本号跟随主版本

例:`Android 1.0.0` / `iOS 1.0.0` / `Desktop 1.0.0` 同步发布。

## 九、CI/CD 基础配置(预留)

未来 GitHub Actions 模板(等仓库创建后配置):
- `build.yml`:每次 push 触发构建,产出 debug APK
- `release.yml`:tag 推送触发构建,产出签名 release APK
- `pr-check.yml`:PR 检查(编译、单元测试、lint)
- `release-please.yml`:自动 CHANGELOG + tag

---

**总结一句话**:Commit 守规范(Coventional Commits)+ 工具自动化(release-please)+ 流程闭环(PR + tag + release)→ 每次变动都"自动"留痕。
