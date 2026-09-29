// Smoke test for the UME example app.
//
// 说明：原文件是 `flutter create` 生成的计数器模板测试（期待 "0"/"1" 文本），
// 但 example 是 UME 的演示应用，并没有计数器 UI，因此该测试从来无法通过。
// 这里改为验证主页面能被正常渲染（需按 main.dart 的方式提供 UMESwitch）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:example/home_page.dart';
import 'package:example/ume_switch.dart';

void main() {
  testWidgets('HomePage renders the UME demo title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UMESwitch(),
        child: const MaterialApp(
          home: HomePage(title: 'UME Demo Home Page'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('UME Demo Home Page'), findsOneWidget);
  });
}
