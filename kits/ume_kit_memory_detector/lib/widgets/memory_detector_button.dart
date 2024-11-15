import 'package:flutter/material.dart';

import '../leak_info.dart';
import '../memory_detector.dart';
import '../ume_kit_memory_detector.dart';
import 'leaked_info_page.dart';
import 'popup_window.dart';
import 'package:ume_core/ume_core.dart';

/// 作者：李佳奇
/// 日期：2022/4/25
/// 备注：泄露信息入口按钮
class MemoryDetectorButton extends StatefulWidget implements Pluggable {
  MemoryDetectorButton({Key? key}) : super(key: key);

  OverlayEntry? entry;

  bool isOpen = false;

  BuildContext? ctx;

  @override
  State<StatefulWidget> createState() {
    return MemoryDetectorButtonState();
  }

  @override
  Widget buildWidget(BuildContext? context) {
    ctx = context;
    return SizedBox();
  }

  @override
  String get displayName => 'memory_detector';

  @override
  ImageProvider<Object> get iconImageProvider =>
      AssetImage('assets/detectc.png', package: 'ume_kit_memory_detector');

  @override
  String get name => 'memory_detector';

  @override
  void onTrigger() {
    isOpen = !isOpen;
    UmeKitMemoryDetector().switchDetector(!isOpen);
    if (isOpen) {
      if (entry == null) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          entry = OverlayEntry(builder: (_) => MemoryDetectorButton());
          Overlay.of(ctx!)?.insert(entry!);
        });
      }
    } else {
      entry?.remove();
      entry = null;
    }
  }
}

class MemoryDetectorButtonState extends State<MemoryDetectorButton> {
  List<LeakedInfo> cache = [];

  double btnLeft = 10;
  double btnTop = 200;

  OverlayEntry? entry;

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      btnLeft += details.delta.dx;
      btnTop += details.delta.dy;
    });
  }

  @override
  void initState() {
    super.initState();
    UmeKitMemoryDetector().infoStream.listen((event) {
      cache.add(event!);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double btnWidth = 48;
    final Size size = MediaQuery.of(context).size;
    return Positioned(
      left: btnLeft.clamp(0, size.width - btnWidth),
      top: btnTop.clamp(0, size.height - btnWidth),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () async {
            if (cache.isEmpty) return;
            if (entry == null) {
              entry = OverlayEntry(
                  builder: (_) => LeakedInfoPage(
                        leakInfoList: cache,
                        popCallback: () {
                          entry?.remove();
                          entry = null;
                          cache.clear();
                          setState(() {});
                        },
                      ));
              Overlay.of(context)?.insert(entry!);
            }
          },
          onPanUpdate: _dragUpdate,
          child: Container(
            width: btnWidth, height: btnWidth,
            //padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            child: StreamBuilder(
              stream: UmeKitMemoryDetector().taskPhaseStream,
              builder: (BuildContext context,
                  AsyncSnapshot<DetectTaskEvent> snapshot) {
                if (snapshot.data?.phase == null)
                  return const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 40,
                  );
                final double progress =
                    ((snapshot.data!.phase.index + 1) / 6) * 100;
                switch (snapshot.data!.phase) {
                  case TaskPhase.startDetect:
                  case TaskPhase.startGC:
                  case TaskPhase.endGC:
                  case TaskPhase.startAnalyze:
                  case TaskPhase.endAnalyze:
                    return Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    );
                  case TaskPhase.endDetect:
                    if (cache.isEmpty) {
                      return const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                        size: 40,
                      );
                    } else {
                      return const Icon(
                        Icons.system_security_update_warning_rounded,
                        color: Colors.red,
                      );
                    }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
