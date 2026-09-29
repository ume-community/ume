import 'package:flutter/material.dart';

/// @date 4/21/21
/// describe:
class MonitorActionWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final String? title;

  const MonitorActionWidget({
    Key? key,
    this.onTap,
    this.child,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.black.withOpacity(0.7),
        ),
        child: child ?? _defaultWidget(),
      ),
    );
  }

  _defaultWidget() {
    return Text(
      title ?? '',
      style: TextStyle(color: Colors.white),
    );
  }
}
