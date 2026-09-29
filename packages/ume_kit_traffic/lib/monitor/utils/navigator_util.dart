import 'package:flutter/material.dart';

/// @date 9/7/22
/// describe:
class NavigatorUtil {
  static void pushPage(BuildContext context, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => child));
  }
}
