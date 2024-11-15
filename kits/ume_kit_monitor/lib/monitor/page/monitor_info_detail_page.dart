import 'dart:io';

import 'package:flutter/material.dart';

/// @date 2021/6/5
/// describe:错误消息详情页面

class MonitorInfoDetailPage extends StatefulWidget {
  final String? fileName;

  const MonitorInfoDetailPage({Key? key, this.fileName}) : super(key: key);

  @override
  _MonitorInfoDetailPageState createState() => _MonitorInfoDetailPageState();
}

class _MonitorInfoDetailPageState extends State<MonitorInfoDetailPage> {
  String? _content;

  @override
  void initState() {
    super.initState();
    _content = File(widget.fileName!).readAsStringSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName ?? '',
          maxLines: 3,
          style: TextStyle(fontSize: 12),
        ),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      child: Text(_content ?? ''),
    );
  }
}
