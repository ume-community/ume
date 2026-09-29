///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 17:28
///
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ume_core/ume_core.dart';
import 'package:ume_kit_get_connect/ume_kit_get_connect.dart';

import 'mock_classes.dart';

final GetConnect _connect = GetConnect();

void main() {
  group('ConsolePanel', () {
    test('Pluggable', () {
      final GetConnectInspector pluggable =
          GetConnectInspector(connect: _connect);
      final Widget widget = pluggable.buildWidget(MockContext());
      final String name = pluggable.name;
      final VoidCallback onTrigger = pluggable.onTrigger..call();
      final ImageProvider imageProvider = pluggable.iconImageProvider;

      expect(widget, isA<Widget>());
      expect(name, isNotEmpty);
      expect(onTrigger, isA<Function>());
      expect(imageProvider, isNotNull);
    });

    testWidgets('GetConnectInspector pump widget', (tester) async {
      final GetConnectInspector inspector =
          GetConnectInspector(connect: _connect);
      await tester.pumpWidget(
        MaterialApp(key: rootKey, home: Scaffold(body: inspector)),
      );
      await tester.pumpAndSettle();
      expect(inspector, isNotNull);
    });
  });
}
