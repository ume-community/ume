import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ume_core/ume_core.dart';

import 'icon.dart' as icon;

class DarkSide extends StatefulWidget implements Pluggable {
  final BuildContext context;

  DarkSide({required this.context});

  @override
  State<DarkSide> createState() => _DarkSideState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'DarkSide';

  @override
  String get displayName => 'DarkSide';

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  void onTrigger() {}
}

class _DarkSideState extends State<DarkSide> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryBrightness = MediaQuery.platformBrightnessOf(context);
    final platformDispatcherBrightness =
        PlatformDispatcher.instance.platformBrightness;
    final themeBrightness = Theme.of(context).brightness;

    debugPrint(
        'MediaQuery.platformBrightnessOf(context): $mediaQueryBrightness');
    debugPrint(
        'PlatformDispatcher.instance.platformBrightness: $platformDispatcherBrightness');
    debugPrint('Theme.of(context).brightness: $themeBrightness');

    return Container(
      child: Row(
        children: [
          Text('Dark/Light'),
          IconButton(
            onPressed: () {
              setState(() {
                changeBrightness();
              });
            },
            icon: Icon(Icons.brightness_4),
          ),
        ],
      ),
    );
  }

  void changeBrightness() {
    //! TODO: app端更新主题后需要电脑端hot reload（setstate并不能触发）
    debugPrint('DarkSide onTrigger');

    debugBrightnessOverride = debugBrightnessOverride == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    PlatformDispatcher.instance.onPlatformBrightnessChanged?.call();
    PlatformDispatcher.instance.onPlatformConfigurationChanged?.call();
  }
}
