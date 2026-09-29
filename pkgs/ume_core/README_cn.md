# UME Core

UME Core 是 UME 的核心库，包含 UME 框架和基础组件。

如果你需要使用 UME 内置的组件，只需在 `pubspec.yaml` 中添加 `ume` 即可，而无需添加 `ume_core`。

如果你需要开发自定义 UME 插件，或使用非内置的组件，则需要添加 `ume_core` 。

## 为 UME 开发插件

> UME 插件位于 `./kits` 目录下，每个插件包都是一个 `package`
> 本小节示例可参考 [`./custom_plugin_example`](./custom_plugin_example/)

1. `flutter create -t package custom_plugin` 创建一个插件包，可以是 `package`，也可以是 `plugin`
2. 修改插件包的 `pubspec.yaml`，添加依赖

   ```yaml
   dependencies:
     ume: ">=2.0.0 <3.0.0"
   ```

3. 创建插件配置，实现 `Pluggable` 虚类

   ```dart
   import 'package:ume_core/ume_core.dart';

   class CustomPlugin implements Pluggable {
     CustomPlugin({Key key});

     @override
     Widget buildWidget(BuildContext context) => Container(
       color: Colors.white
       width: 100,
       height: 100,
       child: Center(
         child: Text('Custom Plugin')
       ),
     ); // 返回插件面板

     @override
     String get name => 'CustomPlugin'; // 插件名称

     @override
     String get displayName => 'CustomPlugin';

     @override
     void onTrigger() {} // 点击插件面板图标时调用

     @override
     ImageProvider<Object> get iconImageProvider => NetworkImage('url'); // 插件图标
   }
   ```

4. 在工程中引入自定义插件

   1. 修改 `pubspec.yaml`，添加依赖

      ```yaml
      dev_dependencies:
        custom_plugin:
          path: path/to/custom_plugin
      ```

   2. 执行 `flutter pub get`

   3. 引入包

      ```dart
      import 'package:custom_plugin/custom_plugin.dart';
      ```

5. 在工程中注册插件

   ```dart
   if (kDebugMode) {
     PluginManager.instance
       ..register(CustomPlugin());
     runApp(
       UMEWidget(
         child: MyApp(),
         enable: true
       )
     );
   } else {
     runApp(MyApp());
   }
   ```

6. 运行代码

### 快速集成嵌入式插件

自 `0.3.0` 版本起引入了 `PluggableWithNestedWidget`，用以实现在 Widget tree 中插入嵌套 Widget，快速接入嵌入式插件。

可参考 [./kits/ume_kit_ui/lib/components/color_picker/color_picker.dart](https://github.com/bytedance/ume/blob/master/kits/ume_kit_ui/lib/components/color_picker/color_picker.dart) 与 [./kits/ume_kit_ui/lib/components/touch_indicator/touch_indicator.dart](https://github.com/bytedance/ume/blob/master/kits/ume_kit_ui/lib/components/touch_indicator/touch_indicator.dart)。

集成重点如下：

1. 插件主体类实现 `PluggableWithNestedWidget`
2. 实现 `Widget buildNestedWidget(Widget child)`，在该方法中处理嵌套结构并返回 Widget
