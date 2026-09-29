import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'leaked_info_page.dart';

import '../leak_info.dart';
import 'detail_button_widget.dart';

/// 作者：李佳奇
/// 日期：2022/4/22
/// 备注：泄露信息条目

class LeakInfoItemWidget extends StatelessWidget {
  const LeakInfoItemWidget(
      {Key? key,
      required this.node,
      required this.isFirst,
      required this.isLast,
      required this.lineColor})
      : super(key: key);

  final RetainingNode node;

  final bool isFirst;

  final bool isLast;

  final Color lineColor;

  bool get hasField => node.parentField != null;

  bool get hasSourceCodeLocation => node.sourceCodeLocation != null;

  bool get showSourceCodeLocation =>
      hasSourceCodeLocation &&
      _shouldShowCode(
          node.sourceCodeLocation!, node.leakedNodeType, node.parentField);

  bool get hasMoreInfo =>
      node.parentKey != null ||
      node.parentIndex != null ||
      showSourceCodeLocation;

  bool get last => isLast && !hasMoreInfo;

  double get height => node.closureInfo != null ? 72.0 : 64.0;

  bool _shouldShowCode(SourceCodeLocation sourceCodeLocation,
      LeakedNodeType nodeType, String? parentField) {
    switch (nodeType) {
      case LeakedNodeType.field:
      case LeakedNodeType.unknown:
        return true;
      case LeakedNodeType.widget:
      case LeakedNodeType.element:
        if (parentField == null) return false;
        if (parentField.startsWith('_child@') ||
            parentField.startsWith('_children@')) {
          return false;
        }
        break;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          color: isFirst ? Colors.red : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                height: height,
                width: 30,
                child: CustomPaint(
                  painter: NodeCustomPainter(!isFirst, !last, lineColor),
                ),
              ),
              10.hSpace,
              Expanded(child: _buildHeader()),
              DetailBtnWidget(
                node: node,
              ),
            ],
          ),
        ),
        //代码位置
        if (showSourceCodeLocation) _buildCodePosition(),
        //列表位置
        if (node.parentIndex != null) _buildIndexOfParent(),
        //所属key信息
        if (node.parentKey != null) _buildKeyInfo(),
        if (hasMoreInfo) _buildMoreWidget(),
        Container(
          height: 0.8,
          color: Colors.white70,
        ),
      ],
    );
  }

  ///见[_buildHeader]
  Widget _builNoneClosureHeader() {
    return RichText(
      text: TextSpan(
        text: node.clazz,
        children: [
          if (hasField)
            const TextSpan(
              text: '.',
            ),
          if (hasField)
            TextSpan(
              text: node.parentField ?? '',
              style: TextStyle(
                color:
                    isFirst ? const Color(0xFFE4EB84) : const Color(0xFFC0BEEA),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (node.leakedNodeType != LeakedNodeType.unknown)
            TextSpan(
              text: ' (${_getNodeTypeString(node.leakedNodeType)})',
              style: const TextStyle(
                color: Color(0xffebcf81),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
        style: TextStyle(
          // color: node.important ? Color(0xFFFFFFFF) : Color(0xFFF5F5F5),
          color: isFirst ? const Color(0xFFFFFFFF) : const Color(0xFFF5F5F5),
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }

  ///见[_buildHeader]
  Widget _buildClosureHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RichText(
          text: TextSpan(
            text: 'Closure',
            children: [
              TextSpan(
                text:
                    '\u00A0\u00A0funName:${node.closureInfo?.closureFunctionName ?? ''}',
                style: const TextStyle(
                  color: Color(0xFFC0BEEA),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
            style: const TextStyle(
              color: Color(0xFF7AD1B4),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        RichText(
          text: TextSpan(
            text: node.closureInfo?.closureOwnerClass == null
                ? 'uri:${node.closureInfo?.libraries ?? ''}'
                : 'class:${node.closureInfo?.closureOwnerClass ?? ''}',
            children: [
              if (node.closureInfo?.funLine != null)
                TextSpan(
                  text:
                      '#${node.closureInfo?.funLine}:${node.closureInfo?.funColumn}',
                  style: const TextStyle(
                    color: Color(0xFFE7D28F),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
            style: const TextStyle(
              color: Color(0xFFC0BEEA),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  ///节点头部
  Widget _buildHeader() {
    return node.closureInfo == null
        ? _builNoneClosureHeader()
        : _buildClosureHeader();
  }

  ///代码位置
  Widget _buildCodePosition() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: 30,
              child: Center(
                child: Container(
                  color: lineColor,
                  width: _strokeWidth,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFAFAFA), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: Colors.blueAccent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: RichText(
                text: TextSpan(
                  text: node.sourceCodeLocation?.code ?? '',
                  children: [
                    TextSpan(
                      text: '\n\n${node.sourceCodeLocation?.uri ?? ''}',
                      style: const TextStyle(
                        color: Color(0xFFE2E2E2),
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    if (node.sourceCodeLocation?.lineNum != null)
                      TextSpan(
                        text: '#${node.sourceCodeLocation?.className ?? ''}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    if (node.sourceCodeLocation?.lineNum != null)
                      TextSpan(
                        text:
                            '#${node.sourceCodeLocation?.lineNum}:${node.sourceCodeLocation?.columnNum}',
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                  ],
                  style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexOfParent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: 30,
              child: Center(
                child: Container(
                  color: lineColor,
                  width: _strokeWidth,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFAFAFA), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: const Color(0xff225fa2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: RichText(
                text: TextSpan(
                  text: 'List index: ',
                  children: [
                    TextSpan(
                      text: '${node.parentIndex}',
                      style: const TextStyle(
                        color: Color(0xFFE2E2E2),
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                  style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: 30,
              child: Center(
                child: Container(
                  color: lineColor,
                  width: _strokeWidth,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFAFAFA), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: const Color(0xff684327),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: RichText(
                text: TextSpan(
                  text: 'Map key: ',
                  children: [
                    TextSpan(
                      text: '${node.parentKey}',
                      style: const TextStyle(
                        color: Color(0xFFE2E2E2),
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                  style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: 30,
        height: 18,
        child: Center(
          child: Container(
            color: lineColor,
            width: _strokeWidth,
          ),
        ),
      ),
    );
  }

  String _getNodeTypeString(LeakedNodeType leakedNodeType) {
    switch (leakedNodeType) {
      case LeakedNodeType.unknown:
        return 'unknown';
      case LeakedNodeType.widget:
        return 'Widget';
      case LeakedNodeType.element:
        return 'Element';
      case LeakedNodeType.field:
        return 'Field';
    }
  }
}

const _strokeWidth = 2.3;

class NodeCustomPainter extends CustomPainter {
  final bool hasNext;
  final bool hasPre;
  final Color color;

  final Paint _paint = Paint()
    ..color = const Color(0xff1e7ce4)
    ..style = PaintingStyle.fill
    ..strokeWidth = _strokeWidth;

  NodeCustomPainter(this.hasPre, this.hasNext, this.color) {
    _paint.color = color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hasPre) {
      canvas.drawLine(Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height / 2), _paint);
    } else {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, _paint);
    }
    if (hasNext) {
      canvas.drawLine(Offset(size.width / 2, size.height / 2),
          Offset(size.width / 2, size.height), _paint);
      if (hasPre) {
        drawArrow(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NodeCustomPainter oldDelegate) {
    return hasNext != oldDelegate.hasNext;
  }

  void drawArrow(Canvas canvas, Size size) {
    canvas.drawLine(Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2 + 8, size.height / 2 - 10), _paint);
    canvas.drawLine(Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2 - 8, size.height / 2 - 10), _paint);
  }
}
