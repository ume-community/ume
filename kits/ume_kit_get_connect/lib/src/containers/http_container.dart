/*
 * @Author: zdd
 * @Date: 2024-09-14 17:45:22
 * @LastEditors: zdd dongdong@grizzlychina.com
 * @LastEditTime: 2024-09-14 18:27:23
 * @FilePath: http_container.dart
 */
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart' show FirstWhereExt, Response;

const _defaultDuration = Duration(seconds: 60);

/// Implements a [ChangeNotifier] to notify listeners when new responses
/// were recorded. Use [page] to support paging.
class HttpContainer extends ChangeNotifier {
  /// Store all responses.
  List<Response<dynamic>> get requests => _requests;
  final List<Response<dynamic>> _requests = <Response<dynamic>>[];

  /// Paging fields.
  int get page => _page;
  int _page = 1;
  final int _perPage = 10;

  List<String> throttlePaths = [];

  /// Return requests according to the paging.
  List<Response<dynamic>> get pagedRequests {
    return _requests.sublist(0, math.min(page * _perPage, _requests.length));
  }

  bool get _hasNextPage => _page * _perPage < _requests.length;

  void addRequest(Response<dynamic> response) {
    void insert() {
      _requests.insert(0, response);
      notifyListeners();
    }

    if (throttlePaths.isNotEmpty &&
        throttlePaths.firstWhereOrNull(
                (e) => response.request?.url.path.contains(e) == true) !=
            null) {
      execute(response.request!.url.path, insert);
    } else {
      insert();
    }
  }

  void loadNextPage() {
    if (!_hasNextPage) {
      return;
    }
    _page++;
    notifyListeners();
  }

  void resetPaging() {
    _page = 1;
    notifyListeners();
  }

  void clearRequests() {
    _requests.clear();
    _page = 1;
    notifyListeners();
  }

  final Map<String, Timer> _wrappers = {};

  void execute(String sign, void Function() function,
      {Duration duration = _defaultDuration}) {
    if (_wrappers.containsKey(sign)) {
      return;
    } else {
      function.call();
    }

    _wrappers[sign] = Timer(
      duration,
      () {
        _wrappers[sign]?.cancel();
        _wrappers.remove(sign);
      },
    );
  }

  ///在state的dispose方法里移除Timer
  void remove(String sign) {
    if (_wrappers.containsKey(sign)) {
      _wrappers[sign]?.cancel();
      _wrappers.remove(sign);
    }
  }

  ///移除所有Timer
  void clear() {
    _wrappers.forEach((key, value) {
      remove(key);
    });
    _wrappers.clear();
  }

  HttpContainer() {
    debugPrint('HttpContainer init');
  }

  @override
  void dispose() {
    _requests.clear();
    clear();
    super.dispose();
  }
}
