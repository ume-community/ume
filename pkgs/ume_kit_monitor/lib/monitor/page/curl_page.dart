import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_shrink_widget/json_shrink_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ume_kit_monitor/monitor/awesome_monitor.dart';
import 'package:ume_kit_monitor/monitor/monitor_message_notifier.dart';
import 'package:ume_kit_monitor/monitor/utils/inner_utils.dart';
import 'package:ume_kit_monitor/monitor/utils/navigator_util.dart';
import 'package:ume_kit_monitor/monitor/widgets/input_panel_field.dart';

import 'log_recorder_page.dart';

/// @date 2020/12/17
/// describe:
class CurlPage extends StatefulWidget {
  final String? tag;

  const CurlPage({Key? key, this.tag}) : super(key: key);

  @override
  _CurlPageState createState() => _CurlPageState();
}

class _CurlPageState extends State<CurlPage> {
  ///匹配中括号内容
  static RegExp _regex = RegExp(r"\[([^\[\]]*)\]");

  ///更新正则,已匹配转义后的链接
  static RegExp _regexUrl = RegExp(
      r"(https?|ftp|file):(//|\\/\\/)[-A-Za-z0-9+&@#/\%?\\/=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"); //匹配url

  ///都是正则匹配,为此为数据添加临时缓存widget,以进一步提高性能
  static Map<String?, Map<String?, Widget?>> _tabWidgetCached = Map();

  TextEditingController _controller = TextEditingController();
  List<String> _filerDatas = [];
  BuildContext? _context;

  @override
  void initState() {
    _controller.addListener(() => _startFilter(updateView: true));
  }

  _startFilter({bool updateView = false}) {
    if (InnerUtils.isEmpty(_controller.text)) {
      if (updateView) {
        setState(() {
          _filerDatas.clear();
        });
      } else {
        _filerDatas.clear();
      }
      return;
    }
    //三个字起触发搜索
    if (_controller.text.length > 3) {
      MonitorMessageNotifier<String>? notifier =
          Monitor.instance.getNotifier(widget.tag);
      if (notifier?.message != null && notifier!.message!.isNotEmpty) {
        _filerDatas.clear();
        for (int i = 0; i < notifier.message!.length; i++) {
          String msg = notifier.message![i];
          if (msg.contains(_controller.text)) {
            _filerDatas.add(msg);
          }
        }
        if (_filerDatas.isNotEmpty && updateView) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    MonitorMessageNotifier<String>? notifier =
        Monitor.instance.getNotifier(widget.tag);
    //当点击清空时,缓存的widget也进行清空
    if (notifier?.message == null || notifier!.message!.isEmpty) {
      _tabWidgetCached[widget.tag]?.clear();
    }
    _context = context;
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier!.notifier!,
      builder: (_, List<String> datas, child) {
        if (widget.tag == 'Curl' ||
            widget.tag == 'AesDecode' ||
            widget.tag == 'AesDecodes') {
          _startFilter();
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputPanelField(
                      hintText: '输入关键字以搜索接口',
                      controller: _controller,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      NavigatorUtil.pushPage(context, LogRecorderPage());
                    },
                    icon: Icon(Icons.view_list_sharp, color: Colors.white),
                  ),
                ],
              ),
              Expanded(child: _buildListView(datas)),
            ],
          );
        }
        return _buildListView(datas);
      },
    );
  }

  _buildListView(List<String>? datas) {
    List<String>? results = datas;
    if (!InnerUtils.isEmpty(_controller.text)) {
      results = _filerDatas;
    }
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        itemBuilder: (_, index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () {
              String content = index >= results!.length ? "" : results[index];
              if (InnerUtils.isEmpty(content)) {
                return;
              }
              if (widget.tag == 'Curl' && content.startsWith("curl -X GET")) {
                //只有Get 的请求可以直接访问
                Iterable<RegExpMatch> matchers = _regexUrl.allMatches(content);
                if (matchers.isNotEmpty) {
                  String? regexText = matchers.elementAt(0).group(0);
                  if (!InnerUtils.isEmpty(regexText)) {
                    InnerUtils.jumpLink(regexText);
                  }
                }
              }
            },
            onLongPress: () {
              String content = index >= results!.length ? "" : results[index];
              //复制页面名字时，做特殊处理
              if (widget.tag == 'Page') {
                //page页面复制,只复制最后的字段
                content = content.split('/').last;
              }
              Clipboard.setData(ClipboardData(text: content));
              showToast('复制成功');
            },
            child: _buildCachedWidget(
                index >= results!.length ? "" : results[index]),
          ),
        ),
        itemCount: results?.length ?? 0,
      ),
    );
  }

  _buildText(String text) {
    //处理Curl相关的数据
    if (widget.tag == 'Curl' && !InnerUtils.isEmpty(_controller.text)) {
      text = text.replaceAll(_controller.text, '[${_controller.text}]');
      return _formatColorRichText(text, [
        TextStyle(color: Colors.white),
        TextStyle(color: Colors.red),
      ]);
    }

    //处理请求结果返回的数据
    if (widget.tag == 'AesDecode' || widget.tag == 'AesDecodes') {
      int index = text.indexOf('\n');
      String highLightText = text.substring(0, index);
      text = text.substring(index + 1, text.length);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InnerUtils.isEmpty(_controller.text)
              ? Text(highLightText, style: TextStyle(color: Colors.cyanAccent))
              : _formatColorRichText(
                  highLightText.replaceAll(
                      _controller.text, '[${_controller.text}]'),
                  [
                    TextStyle(color: Colors.cyanAccent),
                    TextStyle(color: Colors.red),
                  ],
                ),
          JsonShrinkWidget(json: text, deepShrink: 1),
        ],
      );
    }
    //普通文本数据
    return Text(text, style: TextStyle(color: Colors.white));
  }

  ///通过判断缓存是否有widget,减少正则匹配的次数
  _buildCachedWidget(String text) {
    if (InnerUtils.isEmpty(text)) return Text('');
    String key = InnerUtils.generateMd5(text + _controller.text);
    Map<String?, Widget?>? cached = _tabWidgetCached[widget.tag];
    if (cached == null) {
      cached = Map();
      _tabWidgetCached[widget.tag] = cached;
    }
    Widget? child = cached[key];
    if (child == null) {
      child = _buildText(text);
      cached[key] = child;
    }
    return child;
  }

  //第一个颜色为文本的默认颜色,其它颜色为为格式化的富文本的颜色,匹配中括号内的东西,中括号内的作为富文本不同颜色的部分,
  // 正则匹配中括号的东西,传入的TextStyle列表,给对应中括号内容,设置不同颜色风格
  RichText _formatColorRichText(
    String content,
    List<TextStyle> styles, {
    TextAlign textAlign = TextAlign.left,
    TextOverflow overflow = TextOverflow.visible,
  }) {
    List<TextSpan> spans = [];
    Iterable<RegExpMatch> matchers = _regex.allMatches(content);
    //第二个开始才是真正需要格式化的颜色
    int count = 1;
    TextStyle? style;
    for (Match m in matchers) {
      if (count < styles.length) {
        style = styles[count];
      }
      String? regexText = m.group(0);
      int index = content.indexOf(regexText!);
      //匹配出来的普通文本
      spans.add(TextSpan(text: content.substring(0, index)));
      content = content.substring(index, content.length);
      //切割余下的文本,去掉中括号,留下文本内容
      spans.add(TextSpan(
          text: regexText.substring(1, regexText.length - 1), style: style));
      content = content.substring(regexText.length, content.length);
      count++;
    }
    //剩余最后的内容
    spans.add(TextSpan(text: content));
    return RichText(
      textAlign: textAlign,
      overflow: overflow,
      text: TextSpan(
        text: '',
        style: styles[0],
        children: spans,
      ),
    );
  }
}
