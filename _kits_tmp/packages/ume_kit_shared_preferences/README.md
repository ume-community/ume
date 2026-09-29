# ume_kit_shared_preferences

基于 UME 下的 shared_preferences 插件，可以实时查看修改或删除所有 shared_preferences 缓存的 key 的值。

## 接入 UME Example

只需把整个 ume_kit_shared_preferences 放入 kit 中本地导入。修改 pubspec 如下 即可

```
ume_kit_shared_preferences:
    path: ../kits/ume_kit_shared_preferences

```

main.dart 新增如下代码，SharedPreferencesInspector 模块即可带入 UME 主模块。

```

..register(SharedPreferencesInspector())

```

## 不接入 Example 运行

不接入的话，本项目也带有 demo main.dart 可以直接运行，详情可以看 screenshots 下录制的视频。 实测支持 iOS、安卓、macos。 理论所有 shared_preferences 插件支持的平台都支持，但是手上没有 Linux、Windows 平台机器。故而不做保证。
