# UME Core

UME Core is the core library of UME, including the UME framework and basic components.

If you need to use UME's built-in components, just add `ume` to your `pubspec.yaml` without adding `ume_core`.

If you need to develop custom UME plugins or use non-built-in components, you need to add `ume_core`.

## Develop plugin kits for UME

> UME plugins are located in the `./kits` directory, and each one is a `package`.
> You can refer to the example in [`./custom_plugin_example`](./custom_plugin_example/) about this chapter.

1. Run `flutter create -t package custom_plugin` to create your custom plugin kit, it could be `package` or `plugin`.
2. Edit `pubspec.yaml` of the custom plugin kit to add UME framework dependency.

   ```yaml
   dependencies:
     ume_core: ^2.0.0
   ```

3. Create the class of the plugin kit which should implement `Pluggable`.

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
     ); // The panel of the plugin kit

     @override
     String get name => 'CustomPlugin'; // The name of the plugin kit

     @override
     String get displayName => 'CustomPlugin';

     @override
     void onTrigger() {} // Call when tap the icon of plugin kit

     @override
     ImageProvider<Object> get iconImageProvider => NetworkImage('url'); // The icon image of the plugin kit
   }
   ```

4. Use your custom plugin kit in project

   1. Edit `pubspec.yaml` of host app project to add `custom_plugin` dependency.

      ```yaml
      dev_dependencies:
        custom_plugin:
          path: path/to/custom_plugin
      ```

   2. Run `flutter pub get`

   3. Import package

      ```dart
      import 'package:custom_plugin/custom_plugin.dart';
      ```

5. Edit main method of your app, register your custom_plugin plugin kit

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

6. Run your app

### Access the nested widget debug kits quickly

We introduce the `PluggableWithNestedWidget` from `0.3.0`. It is used to insert nested Widgets in the Widget tree and quickly access embedded kits with nested widget.

For more details, see [./kits/ume_kit_ui/lib/components/color_picker/color_picker.dart](https://github.com/bytedance/ume/blob/master/kits/ume_kit_ui/lib/components/color_picker/color_picker.dart) and [./kits/ume_kit_ui/lib/components/touch_indicator/touch_indicator.dart](https://github.com/bytedance/ume/blob/master/kits/ume_kit_ui/lib/components/touch_indicator/touch_indicator.dart).

The key steps are as follows:

1. The class of your plugin should implement `PluggableWithNestedWidget`.
2. Implements `Widget buildNestedWidget(Widget child)`. Handling the nested widgets and returning the new Widget.
