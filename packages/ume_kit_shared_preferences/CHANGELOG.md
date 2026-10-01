# ume_kit_shared_preferences

## 2.0.3

* 演示 app 迁移到 example/ 子目录（Flutter 官方约定）
  - android/ ios/ macos/ 与 lib/main.dart 移入 example/
  - 包根只保留 lib/ 与 test/，发布包体积 139 KB -> 6 KB
  - 新增 example/pubspec.yaml，演示 app 仍可独立 flutter run
* 移除 example 的 CocoaPods 集成（插件已全部走 Swift Package Manager）

## 2.0.2

* 依赖升级：`cupertino_icons` ^1.0.2 -> ^2.0.0

## 2.0.1

* 仓库迁移至 https://github.com/insightop/ume
* 依赖升级到最新版本
* 源码迁至主仓库 packages/ 下（单仓库 pub workspace）

## 0.0.2

Remove snapshots in package

## 0.0.1

Initial commit.
