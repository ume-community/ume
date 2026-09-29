

import 'package:flutter/material.dart';

import '../model/package_model.dart';

///channel 调用记录的展示页面
class RecentChannelRecordPage extends StatefulWidget{

  const RecentChannelRecordPage({Key? key, required this.records, required this.popCallback}) : super(key: key);

  final List<ChannelModel> records;

  final Function popCallback;

  @override
  State<StatefulWidget> createState() {
    return RecentChannelRecordPageState();
  }

}

class RecentChannelRecordPageState extends State<RecentChannelRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('recently channel record'),
          leading: GestureDetector(
            onTap: () {
              widget.popCallback.call();
            },
            child: const Icon(Icons.chevron_left, color: Colors.white,),
          ),
        ),
        body: ListView(
          children: widget.records.map<Widget>(_buildItem).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(ChannelModel model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(5),
      color: Colors.grey[300],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('channel name: ${model.channelName}', style: const TextStyle(color: Colors.red, fontSize: 18),),
          Text('method name : ${model.methodName}', style: const TextStyle(color: Colors.lightBlue, fontSize: 16)),
          Text('invoke time : ${DateTime.fromMillisecondsSinceEpoch(model.sendTimestamp)}',
              style: const TextStyle(color: Colors.green, fontSize: 14)),
          const SizedBox(width: 1, height: 5,),
          Text('detail : ${model.getPackage().toString()}'),
        ],
      ),
    );
  }

}















