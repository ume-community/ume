import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ume_core/ume_core.dart';
import 'memory_detector.dart';

export 'widgets/memory_detector_button.dart';

///引用链最大长度
/// * 见 [VmService.getRetainingPath]
const int maxRetainingPath =
    int.fromEnvironment("maxRetainingPath", defaultValue: 400);

///关闭内存检测
///
/// * 更多见 ： [MemoryDetector.switchDetector]
const bool closeMemDetector =
    bool.fromEnvironment("closeMemDetector", defaultValue: false);

///延迟检测
/// * 单位 : 毫秒
/// * 部分对象并不会及时回收
const int delayDoDetect =
    int.fromEnvironment('delayDoDetect', defaultValue: 800);

///扩展单元数量
/// * 在gc前创建[expandUnitNumber]个对象，用于触发full gc
/// * 0则不创建。
/// * 在实际项目接入中，由于项目所占用的内存，默认值可能过大，建议根据需求调整。
const int expandUnitNumber =
    int.fromEnvironment('expandUnitNumber', defaultValue: 100000);

///内存检测工具
/// * 切勿在release下运行。
// class UmeKitMemoryDetector extends MemoryDetector with NavigatorObserver {
class UmeKitMemoryDetector extends MemoryDetector implements NavigatorObserver {
  static UmeKitMemoryDetector? _singleton;

  factory UmeKitMemoryDetector() {
    _singleton ??= UmeKitMemoryDetector._();
    return _singleton!;
  }

  UmeKitMemoryDetector._() : super(closeMemDetector);

  @override
  void didPush(Route route, Route? previousRoute) {
    _watch(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _initDetect(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _initDetect(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _watch(newRoute);
    }
    if (oldRoute != null) {
      _initDetect(oldRoute);
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    _watch(route);
  }

  @override
  void didStopUserGesture() {
    // super.didStopUserGesture();
  }
  @override
  NavigatorState? get navigator => null;

  ///加入检测队列
  void _watch(Route route) {
    if (kReleaseMode) return;
    route.didPush().then((value) {
      final element = _getElementByRoute(route);
      if (element != null) {
        final key = _generateRouteKey(route);
        addObject(obj: element, group: key);
        addObject(obj: element.widget, group: key);
        if (element is StatefulElement) {
          addObject(obj: element.state, group: key);
        }
      }
    });
  }

  ///对出栈路由进行检测
  void _initDetect(Route route) async {
    if (kReleaseMode) return;
    await WidgetsBinding.instance?.endOfFrame;
    final element = _getElementByRoute(route);
    if (element != null) {
      final key = _generateRouteKey(route);
      if (element is StatefulElement || element is StatelessElement) {
        doDetect(key);
      }
    }
  }

  Element? _getElementByRoute(Route route) {
    Element? element;
    if (route is ModalRoute) {
      //RepaintBoundary
      route.subtreeContext?.visitChildElements((child) {
        //Builder
        child.visitChildElements((child) {
          //Semantics
          child.visitChildElements((child) {
            //My Page
            element = child;
          });
        });
      });
    }
    return element;
  }

  ///生成分组key
  String _generateRouteKey(Route route) {
    final hashCode = route.hashCode.toString();
    String? key = route.settings.name;
    if (key == null || key.isEmpty) {
      key = hashCode;
    } else {
      key = '$key($hashCode)';
    }
    return key;
  }
}
