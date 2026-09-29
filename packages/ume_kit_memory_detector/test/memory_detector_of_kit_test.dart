import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ume_kit_memory_detector/leak_info.dart';
import 'package:ume_kit_memory_detector/memory_detector.dart';
import 'package:ume_kit_memory_detector/ume_kit_memory_detector.dart';

HashMap leaker = HashMap();

void main() {
  test('test detector', () async {
    String key = leaker.hashCode.toString();
    defaultHandler = (LeakedInfo info) {
      debugPrint(info.toString());
      expect(
          info.retainingPathJson.length, inInclusiveRange(1, double.infinity));
    };
    Completer completer = Completer();

    WidgetsFlutterBinding.ensureInitialized();
    UmeKitMemoryDetector().addObject(obj: leaker, group: key);
    await Future.delayed(const Duration(seconds: 3));
    UmeKitMemoryDetector().doDetect(key);
    UmeKitMemoryDetector().taskPhaseStream.listen((event) async {
      TaskPhase phase = event.phase;
      debugPrint('phase : $phase');
      expect(phase.index, inInclusiveRange(0, 5));
      if (phase == TaskPhase.endDetect) {
        completer.complete();
      }
    });
    return completer.future;
  });
}
