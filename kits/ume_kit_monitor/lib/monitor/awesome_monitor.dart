import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ume_kit_monitor/monitor/monitor_action_widget.dart';
import 'package:ume_kit_monitor/monitor/monitor_message_notifier.dart';
import 'package:ume_kit_monitor/monitor/utils/inner_utils.dart';

///test push two remote url
class Monitor {
  static const String MONITOR_TAG = "MONITOR_TAGS";

  Map<String, MonitorMessageNotifier<String>> _maps = Map();
  static List<MonitorActionWidget>? _actions;

  List<MonitorActionWidget>? get actions => _actions;

  static bool _enable = !bool.fromEnvironment("dart.vm.product");

  static Monitor? _instance;

  List<String> get tabs => _maps.keys.toList();

  factory Monitor() => _getInstance();

  static Monitor get instance => _getInstance();

  static Monitor _getInstance() {
    if (_instance == null) {
      _instance = Monitor._internal();
    }
    return _instance!;
  }

  static void init(BuildContext context, {List<MonitorActionWidget>? actions, bool? forceInit}) async {
    if (_enable) {
      Monitor.instance.addActions(actions);
    } else {
      _actions = actions;
    }
  }

  void addActions(List<MonitorActionWidget>? actions) {
    if (_enable) {
      if (_actions != null && actions != null && _actions != actions) {
        _actions?.addAll(actions);
      } else {
        _actions = actions;
      }
    }
  }

  Monitor._internal();

  MonitorMessageNotifier<String>? getNotifier(String? tag) => _maps[tag];

  void put(String tag, String content, {bool limit = true}) {
    //屏蔽掉刷屏的请求
    if (content.contains("ac=last_msg")) {
      return;
    }
    if (!_enable) {
      return;
    }
    if (InnerUtils.isEmpty(tag)) {
      return;
    }
    MonitorMessageNotifier<String>? notifier = _maps[tag];
    if (notifier == null) {
      notifier = MonitorMessageNotifier<String>();
      _maps[tag] = notifier;
    }
    notifier.add(content, limit: limit);
  }

  void puts(String tag, List<String> contents, {bool limit = true}) {
    if (contents.isEmpty) return;
    for (String content in contents) {
      put(tag, content, limit: limit);
    }
  }

  void putsConsole(List<String> contents, {bool limit = true}) {
    if (contents.isEmpty) return;
    for (String content in contents) {
      put('Console', content, limit: limit);
    }
  }

  void putPage(String page) => put("Page", page);

  void putSocket(String page) => put("Socket", page);

  void putCurl(String curl) => put("Curl", curl);

  void putLogCat(String msg) => put("LogCat", msg);

  void clear(String tag) {
    if ('Error' == tag) {
      _maps[tag]?.message?.forEach((element) {
        File file = File(element);
        if (file.existsSync()) {
          file.delete();
        }
      });
    }
    _maps[tag]?.clear();
  }
}
