import 'package:flutter/material.dart';
import 'leak_info_item_widget.dart';

import '../leak_info.dart';
import '../leaked_info_recorder.dart';

/// 作者：李佳奇
/// 日期：2022/4/22
/// 备注：内存泄露信息页面

const colors = [Colors.yellow, Colors.greenAccent];

class LeakedInfoPage extends StatefulWidget {
  const LeakedInfoPage(
      {Key? key, required this.leakInfoList, required this.popCallback})
      : super(key: key);

  final List<LeakedInfo> leakInfoList;

  final Function popCallback;

  @override
  State<StatefulWidget> createState() {
    return LeakedInfoPageState();
  }
}

class LeakedInfoPageState extends State<LeakedInfoPage> {
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;

  List<RetainingNode> get retainingPath =>
      widget.leakInfoList[_currentIndex].retainingPath;

  String? get gcRootType => widget.leakInfoList[_currentIndex].gcRootType;

  int? get timestamp => widget.leakInfoList[_currentIndex].timestamp;

  DateTime get showDate => DateTime.fromMillisecondsSinceEpoch(timestamp!);

  int get count => retainingPath.length;

  double get paddingBottom => MediaQuery.of(context).padding.bottom;

  void _showPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _scrollController.jumpTo(0.0);
      });
    }
  }

  void _showNext() {
    if (_currentIndex < widget.leakInfoList.length - 1) {
      setState(() {
        _currentIndex++;
        _scrollController.jumpTo(0.0);
      });
    }
  }

  void _deleteFromDatabase() {
    final info = widget.leakInfoList[_currentIndex];
    widget.leakInfoList.removeAt(_currentIndex);
    LeakedInfoDbRecorder().deleteById(info.timestamp!);
    if (widget.leakInfoList.isEmpty) {
      //Navigator.pop(context);
      widget.popCallback.call();
    } else {
      setState(() {
        _scrollController.jumpTo(0.0);
        _currentIndex = _currentIndex.clamp(0, widget.leakInfoList.length - 1);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.popCallback.call();
      },
      child: Material(
        color: Colors.black.withOpacity(0.3),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 1 / 7,
            ),
            _buildTitleBar(),
            _buildLeakPath(),
            _buildPageSwitcher(),
          ],
        ),
      ),
    );
  }

  ///底部控制bar
  /// * 翻页、删除记录
  Widget _buildPageSwitcher() {
    return Container(
      color: const Color(0xFF3F3F3F),
      padding: EdgeInsets.only(bottom: paddingBottom),
      height: 50 + paddingBottom,
      child: Row(
        children: [
          Expanded(
            child: Visibility(
              visible: _currentIndex > 0,
              child: TextButton(
                onPressed: _showPrevious,
                child: const Icon(
                  Icons.navigate_before_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: _deleteFromDatabase,
              style: ButtonStyle(
                padding: MaterialStateProperty.resolveWith(
                    (_) => const EdgeInsets.all(0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red.withOpacity(0.8),
                    size: 23,
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.leakInfoList.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Visibility(
              visible: _currentIndex < widget.leakInfoList.length - 1,
              child: TextButton(
                onPressed: _showNext,
                child: const Icon(
                  Icons.navigate_next_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///泄露路径
  /// * 自顶向下 ： 泄漏点 -> root
  Widget _buildLeakPath() {
    return Expanded(
        child: ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(0),
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        return LeakInfoItemWidget(
            node: retainingPath[index],
            isFirst: index == 0,
            isLast: index == count - 1,
            lineColor: colors[index % colors.length]);
      },
      itemCount: count,
    ));
  }

  Widget _buildTitleBar() {
    return Container(
      height: 40,
      color: const Color(0xFF3E5E87),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'GcRoot type:${gcRootType ?? ''}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${showDate.month}/${showDate.day} ${showDate.hour}:${showDate.minute}:${showDate.second}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

extension NumSpace on num {
  Widget get vSpace => SizedBox(height: toDouble());

  Widget get hSpace => SizedBox(width: toDouble());
}
