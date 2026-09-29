# UME 单仓库重构方案（submodule → pub workspace 单仓库）

> 状态：**待用户确认**
> 作者：DSH agent
> 日期：2026-09-29

---

## 1. 背景与目标

### 现状
```
ume-community/ume        (主仓库, 190 commits, 14MB)  ── submodule ──> ume_core  (13 commits, 58KB)
                                                        └─ submodule ──> ume_kits  (25 commits, 3.2MB)
```

### 目标
1. **合并成一个 git 仓库**（不再用 submodule）
2. 技术上仍用 **Dart 官方 pub workspace**，melos 作为辅助
3. **`example` 保留在 ume 仓库内**
4. 两个旧仓库 `ume_core`、`ume_kits` 在 GitHub 上 **archive**
5. 最终效果：用户只需 `dependencies: ume: ^x.y.z` 即可获得全部能力

---

## 2. 侦察结论（实证，非推测）

| # | 事实 | 证据 |
|---|---|---|
| 1 | **`ume` 已是 façade 包** | `lib/ume.dart` 纯 re-export 全部 kit；根 pubspec 依赖全部 kit |
| 2 | **"只引用一个包"已可用** | 实测消费者 `ume: ^2.0.6` → `pub get` 成功，153 依赖 |
| 3 | **`ume_kit_bloc_inspector` 未发布（404）却是直接依赖** | `curl pub.dev/api/packages/ume_kit_bloc_inspector` → 404；已发布 2.0.6 不含它 |
| 4 | **发布打包整个仓库（10MB）** | 已发布 `ume-2.0.6.tar.gz` 顶层含 `example/ ume_core/ ume_kits/` |
| 5 | **submodule 无法独立检出**（我引入的回归） | `cd ume_core && dart pub get` → "found no workspace root" |
| 6 | **官方先例支持单仓库+workspace+独立发布** | dart-lang/sdk：根 `pubspec.yaml` 列 100+ 包，`analyzer` 等各自发布 pub.dev |
| 7 | **6 个"未发布 kit"是空占位目录** | `ume_kit_appwrite/brick/catcher/firebase/get_it/supabase` 仅含 `.gitkeep` |
| 8 | **发布成员包时 `resolution: workspace` 会保留但不影响消费者** | 已发布 `analyzer-14.4.0` pubspec 含该字段，消费者 `pub get` 正常 |
| 9 | **`.pubignore` 可将发布体积 10MB → 51KB** | 实测：排除 `example/ pkgs/ build/` 后 `Total compressed archive size: 51 KB` |
| 10 | **`ume_kits` 有真实未提交工作（合并前必须保全）** | `ume_kit_bloc_inspector` 为完整新 kit（21 文件）；另有 `dark_side/`、`platform_tab.dart`、`device_info.dart`、`network_tab.dart`、`ume_kit_ui.dart` 改动 |

---

## 3. 目标仓库结构

采用官方 `dart-lang/sdk` 模式（`pkgs/` 集中放包），保留 `example`：

```
ume/                                  ← 单一仓库
├── pubspec.yaml                      ← workspace 根（name: ume, publish_to 保留）
├── pubspec.lock                       ← 唯一 lock（提交）
├── melos.yaml                         ← melos 辅助（脚本/版本/发布编排）
├── .pubignore                         ← ★ 排除 example/、pkgs/，减小发布体积
├── lib/ume.dart                       ← façade（re-export 全部 kit）
├── example/                           ← 保留；Flutter app，publish_to: none
├── pkgs/                              ← 原 ume_kits/packages/* 迁入
│   ├── ume_kit_bloc_inspector/
│   ├── ume_kit_channel_monitor/
│   ├── ...（17 个真实 kit）
│   └── ume_kit_storage/
└── core/                              ← 原 ume_core 迁入（或 pkgs/ume_core）
    └── pubspec.yaml
```

**决策点**：`ume_core` 放 `core/` 还是 `pkgs/ume_core/`？→ 建议 `pkgs/ume_core`，与官方 `pkgs/` 惯例一致，减少顶层目录。

---

## 4. 迁移步骤

### 阶段 A：历史合并（已实测演练通过 ✅）

**演练结果**：用 `git subtree` 在本地克隆上完整跑通——
```
190 (ume) + 13 (ume_core) + 25 (ume_kits) = 231 commits  ✅ 历史完整保留
最终结构: pkgs/ume_core/ + pkgs/ume_kit_*/ (17 个真实 kit)
```

**具体命令**（用本地 `.git/modules/*` 作为 remote，无需网络）：
```bash
# A1. ume_core → pkgs/ume_core
git remote add core_src .git/modules/ume_core
git fetch core_src main
git subtree add --prefix=pkgs/ume_core core_src main

# A2. ume_kits → 先并入临时 prefix，再整理路径
git remote add kits_src .git/modules/ume_kits
git fetch kits_src main
git subtree add --prefix=_kits_tmp kits_src main
git mv _kits_tmp/packages/* pkgs/          # packages/* → pkgs/*
git mv _kits_tmp/LICENSE pkgs/ume_kits_LICENSE
git mv _kits_tmp/README.md pkgs/ume_kits_README.md
rm -rf _kits_tmp
git commit -m "chore: reorganize kits into pkgs/"
```

> **注意**：`git subtree` 只取**已提交**历史。`ume_kits` 的未提交工作（bloc_inspector 等）需在阶段 0 先处置。

### 阶段 A0：保全未提交工作（合并前必须做）

`ume_kits` 未提交内容（实测）：
```
?? packages/ume_kit_bloc_inspector/   ← 完整新 kit，21 个文件（含 lib/、test/、pubspec.yaml）
?? packages/ume_kit_ui/lib/components/dark_side/  ← 2 文件
?? packages/ume_kit_device/lib/src/components/platform_tab.dart
 M packages/ume_kit_device/lib/src/device_info.dart
 M packages/ume_kit_device/lib/src/components/network_tab.dart
 M packages/ume_kit_ui/lib/ume_kit_ui.dart
 D packages/ume_kit_bloc/.gitignore  (原占位目录)
 D packages/ume_kit_bloc/.gitkeep
```
→ **需先在 ume_kits 仓库提交**（或备份后手动搬运），否则 subtree 合并会丢失。


### 阶段 B：pubspec 改造

**实测结论（目标结构已验证 ✅）**：
```
workspace:
  - pkgs/ume_core
  - pkgs/ume_kit_console
  - ...
  - example
dependencies:
  ume_core: ^2.0.2        # workspace 自动解析到本地
  ume_kit_console: ^2.0.0
```
→ `dart pub get` 成功，解析出 `ume`(根) + `pkgs/*` + `example` 全部成员。

**⚠️ 关于 glob `pkgs/*`**（实测）：
| 写法 | SDK 要求 | 结果 |
|---|---|---|
| `pkgs/*` glob | **`>=3.11.0`** | 3.9 报错 "Glob syntax is only supported from language version 3.11" |
| 显式列路径 | `>=3.9.0` | ✅ 通过 |

→ **建议**：用显式路径（保持 3.9 兼容）；若接受把根 SDK 提到 `>=3.11.0`，则可用 glob 自动纳入新增 kit。

| 文件 | 改动 |
|---|---|
| 根 `pubspec.yaml` | 加 `workspace:`；依赖改全部 kit（版本约束） |
| `pkgs/*/pubspec.yaml` | 保留 `resolution: workspace` |
| `pkgs/ume_core/pubspec.yaml` | 保留 `resolution: workspace` |
| 删除 | `.gitmodules`、`ume_core/`、`ume_kits/` |
| 新增 | `.pubignore`（实测 10MB → 51KB） |


### 阶段 C：解决发布阻塞

1. **`ume_kit_bloc_inspector` 必须先发布到 pub.dev**（或从 facade 依赖中移除）
2. **添加 `.pubignore`** 排除非发布内容 —— 实测发布包从 10MB 降到 ~50KB
3. **`CHANGELOG.md` 补 2.0.6 条目**（pub 校验会警告）

### 阶段 D：CI / 自动化

```yaml
# .github/workflows/publish.yml —— tag 触发 + OIDC
on:
  push:
    tags: ['v[0-9]+.[0-9]+.[0-9]+']
jobs:
  publish:
    permissions: { id-token: write }
    uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1
```

- kit 各自发布用独立 tag 前缀（如 `ume_kit_console-v2.0.5`）
- example 构建 + GitHub Release
- Dependabot 路径修正（`/kits/*` → `/pkgs/*`）

### 阶段 E：归档旧仓库

```bash
gh api -X PATCH repos/ume-community/ume_core -f archived=true
gh api -X PATCH repos/ume-community/ume_kits -f archived=true
```
（归档前需在 README 加迁移说明，避免用户困惑）

---

## 5. 关于 `example` 的评估（用户问题）

**结论：放在 ume 仓库内没有问题**，理由与注意点：

| 维度 | 评估 |
|---|---|
| pub workspace 成员？ | **建议是**。`example` 加 `resolution: workspace`，共享单一 lock，依赖本地 kit 无需 override |
| 会否被打进 ume 发布包？ | **会**（现状 2.0.6 就含 example）。用 `.pubignore` 排除 |
| 官方先例 | dart-lang/sdk / core 的 workspace 根**不放 example**，但那是库仓库；Flutter 生态普遍在包内放 `example/`（如 `path_provider/example`） |
| CI 影响 | example 构建可单独 job；失败不应阻塞 kit 发布 |
| 风险 | example 引用了 `dio`、`get`、`flutter_bloc` 等，会进入 workspace 统一依赖解析，可能约束 kit 的依赖上限（**workspace 单锁的固有代价**） |

**替代方案**（若担心 example 污染依赖解析）：`example` 不列入 workspace，改用 `dependency_overrides: path` 指向本地 kit。代价：example 有自己的 lock，需单独 `pub get`。

---

## 6. 风险清单

| 风险 | 影响 | 缓解 |
|---|---|---|
| **subtree 合并丢未提交改动** | 用户的 bloc_inspector 等工作丢失 | 合并前先提交/备份 submodule 未提交内容 |
| **workspace 单锁导致依赖冲突** | example 或某 kit 的依赖上限互相约束 | 先跑 `flutter pub get` 验证；必要时 example 移出 workspace |
| **`ume_kit_bloc_inspector` 未发布** | 发布失败/消费者解析失败 | 先发布该包，或移出 facade |
| **发布体积** | 10MB 包，pub.dev 体验差 | 加 `.pubignore` |
| **归档旧仓库致用户困惑** | 用户找不到 ume_core/ume_kits | 归档前在 README 注明"已迁移至 ume 主仓库" |
| **CI 全红** | submodule 指针 + 路径失效 | 本方案阶段 B/D 一并修复 |
| **历史重写影响 fork** | 有 fork 的用户 | 保留旧仓库（只 archive 不删） |

---

## 7. 待确认问题

1. **`ume_core` 放 `pkgs/ume_core` 还是顶层 `core/`？**
2. **6 个空占位 kit（appwrite/brick/catcher/...）是否清理？**
3. **`ume_kit_bloc_inspector` 先发布，还是从 facade 移除？**
4. **`ume_kits` submodule 里的未提交改动如何处理？**（bloc_inspector、catcher、dark_side、platform_tab 等）
5. **是否接受 workspace 单锁**（example 也在内），还是 example 用 override 隔离？
6. **旧 tag 命名**（历史用 `v0.1.0.1` 这种），新规范用 `v{{version}}`？

---

## 8. 执行顺序建议

```
1. 备份 + 确认未提交改动           (阻塞项，需用户确认)
2. 历史合并 (git subtree)          (可回退)
3. pubspec 改造 + workspace 验证   (flutter pub get)
4. .pubignore + 发布 dry-run 验证
5. CI/Dependabot 编写
6. 推送 + 归档旧仓库
```
