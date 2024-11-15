/*
 * @Author: zdd
 * @Date: 2024-09-14 17:45:22
 * @LastEditors: zdd dongdong@grizzlychina.com
 * @LastEditTime: 2024-09-20 17:50:07
 * @FilePath: pluggable.dart
 */
///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:24
///

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ume_core/core/pluggable.dart';

import 'instances.dart';
import 'models/http_interceptor.dart';
import 'widgets/icon.dart' as icon;
import 'widgets/pluggable_state.dart';

/// Implement a [Pluggable] to integrate with UME.
class GetConnectInspector extends StatefulWidget implements Pluggable {
  GetConnectInspector(
      {Key? key, required this.connect, List<String> throttlePaths = const []})
      : super(key: key) {
    connect.httpClient
        .addRequestModifier<void>(UMEGetConnectInspector.requestInterceptor);
    connect.httpClient
        .addResponseModifier(UMEGetConnectInspector.responseInterceptor);
    InspectorInstance.httpContainer.throttlePaths = throttlePaths;
  }

  final GetConnect connect;

  @override
  GetConnectPluggableState createState() => GetConnectPluggableState();

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'HttpInspector';

  @override
  String get displayName => 'HttpInspector';

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) => this;
}
