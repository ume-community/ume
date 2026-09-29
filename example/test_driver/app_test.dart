import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
    final flutterLogoFinder = find.byTooltip('Open ume panel');

    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('Find tips', () async {
      final diagnostics = await driver.getWidgetDiagnostics(flutterLogoFinder);
      final properties = diagnostics['properties'] as List<dynamic>;
      bool findTip = false;
      for (final m in properties) {
        if (m['value'].toString() == "Open ume panel") {
          findTip = true;
          break;
        }
      }
      expect(findTip, isTrue);
    });

    test('Tap Flutter logo', () async {
      await driver.tap(flutterLogoFinder);
      expect(await driver.getText(find.text('UME')), 'UME');
    });

    test('Drag Flutter logo vertically', () async {
      await driver.runUnsynchronized(() async {
        const double dy = 100;
        await driver.waitFor(flutterLogoFinder);
        final oldPos = await driver.getBottomLeft(flutterLogoFinder);
        await driver.scroll(
            flutterLogoFinder, 0, -dy, Duration(milliseconds: 500));
        final newPos = await driver.getBottomLeft(flutterLogoFinder);
        expect((oldPos.dy - newPos.dy) - dy < 0.00001, true);
      });
    });

    test('Drag Flutter logo horizontally snaps to screen edge', () async {
      await driver.runUnsynchronized(() async {
        await driver.waitFor(flutterLogoFinder);

        // 横向拖拽释放后，浮点会吸附到屏幕左/右边缘（见 RootWidget.dragEnd）。
        // 因此不能断言「位移恰好等于拖拽距离」，而应断言吸附行为本身。
        await driver.scroll(
            flutterLogoFinder, 500, 0, Duration(milliseconds: 500));
        final rightSnapped = await driver.getBottomLeft(flutterLogoFinder);

        await driver.scroll(
            flutterLogoFinder, -500, 0, Duration(milliseconds: 500));
        final leftSnapped = await driver.getBottomLeft(flutterLogoFinder);

        // 吸附到右侧时的 x 必须大于吸附到左侧时的 x，且两者差异明显
        expect(rightSnapped.dx > leftSnapped.dx, true);
      });
    });
  });
}
