import 'package:flutter_test/flutter_test.dart';
import 'package:ume_kit_console/console/console_manager.dart';
import 'package:ume_kit_console/ume_kit_console.dart';

const testMessage = 'Lorem ipsum dolor sit ame';

void main() {
  test('consolePrint', () async {
    consolePrint(testMessage);
    await Future.delayed(Duration.zero);

    final lastLog = ConsoleManager.logData.last.item2;
    expect(lastLog, testMessage);
  });
}
