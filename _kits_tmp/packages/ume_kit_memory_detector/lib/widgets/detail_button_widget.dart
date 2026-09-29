import 'package:flutter/material.dart';
import 'leaked_info_page.dart';

import '../leak_info.dart';

/// 作者：李佳奇
/// 日期：2022/4/24
/// 备注：详情按钮： 显示相关代码

const double _infoCardWidth = 240;
const double _infoCardMinHeight = 180;

class DetailBtnWidget extends StatelessWidget {
  const DetailBtnWidget({Key? key, required this.node}) : super(key: key);

  final RetainingNode node;

  static OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    void popDetail() {
      entry ??= OverlayEntry(builder: (ctx) => _infoCard());
      Overlay.of(context)?.insert(entry!);
      // RenderObject? rb = context.findRenderObject();
      // if(rb is RenderBox) {
      //   Offset pos = rb.localToGlobal(Offset.zero);
      // }
    }

    return GestureDetector(
        onTap: popDetail,
        child: const Icon(Icons.more_horiz, size: 20, color: Colors.white));
  }

  Widget _infoCard() {
    return GestureDetector(
      onTap: () {
        entry?.remove();
        entry = null;
      },
      child: Material(
        color: Colors.grey.withOpacity(0.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _infoCardWidth,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
              decoration: const BoxDecoration(
                color: Color(0xFF686C72),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              constraints: const BoxConstraints(
                  minHeight: _infoCardMinHeight,
                  maxHeight: _infoCardMinHeight * 2),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.closureInfo?.libraries ?? node.libraries ?? '',
                      style: const TextStyle(
                        color: Color(0xFFFFB74D),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    10.vSpace,
                    Text(
                      node.closureInfo?.toString() ?? node.string ?? '',
                      style: const TextStyle(
                        color: Color(0xFFDCE9FA),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(
                      height: 2,
                      color: Colors.white,
                    ),
                    Text(
                      node.sourceCodeLocation?.relativeCode ??
                          node.string ??
                          '',
                      style: const TextStyle(
                        color: Color(0xFFDCE9FA),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
