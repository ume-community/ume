
import 'package:flutter/material.dart';

/// 作者：李佳奇
/// 日期：2022/4/22
/// 备注：底部抽屉和弹窗

///弹窗操控类
/// * [showBottomDrawer] 显示一个drawer
class MemDetectorPopupWindow{

  static Future<Object?> showBottomDrawer(
      BuildContext context,
      Widget view, {
        double? windowHeight,
        Color barrierColor = Colors.black54,
        bool barrierDismissible = true,
        Function(Object? result)? onResult,
      }) async {
    return await Navigator.of(context)
        .push(_BottomPopupWindowRoute(context,
        view, windowHeight, barrierColor, barrierDismissible));
  }

}


class _BottomPopupWindowRoute<T> extends PopupRoute<T> {
  final BuildContext context;
  final Widget view;
  final double? windowHeight;
  final Color _barrierColor;
  final bool _barrierDismissible;

  _BottomPopupWindowRoute(this.context, this.view, this.windowHeight,
      this._barrierColor, this._barrierDismissible);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => _barrierColor;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPopupWindowLayout(animation.value,
                  contentHeight: windowHeight),
              child: view,
            ),
          );
        },
      ),
    );
  }

  @override
  String get barrierLabel =>
      MaterialLocalizations.of(context).modalBarrierDismissLabel;
}


abstract class _PopupWindowLayout extends SingleChildLayoutDelegate {
  final double progress;

  _PopupWindowLayout(this.progress);

  @override
  bool shouldRelayout(_PopupWindowLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// 底部弹窗布局
class _BottomPopupWindowLayout extends _PopupWindowLayout {
  _BottomPopupWindowLayout(double progress, {this.contentHeight})
      : super(progress);

  final double? contentHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: contentHeight ?? constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }
}















