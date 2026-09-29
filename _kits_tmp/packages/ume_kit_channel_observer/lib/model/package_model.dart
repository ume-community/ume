import 'package:flutter/services.dart';

/// 作者：李佳奇
/// 日期：2022/5/2
/// 备注：数据包模型,一般应用于复杂模块的输出标准化
abstract class PackageModel{
  ///记录包
  /// * 可用于上传
  Map<String, String> getPackage();

  ///异常记录包
  bool get isAbnormal;
}

class ChannelModel implements PackageModel{
  ///消息类型
  ///
  /// * [TYPE_DEV_SEND]         开发者发送
  /// * [TYPE_DEV_RECEIVE]      开发者接收
  /// * [TYPE_SYSTEM_SEND]      系统发送
  /// * [TYPE_SYSTEM_RECEIVE]   系统接收
  static const int TYPE_DEV_SEND = 0;
  static const int TYPE_DEV_RECEIVE = 1;
  static const int TYPE_SYSTEM_SEND = 2;
  static const int TYPE_SYSTEM_RECEIVE = 3;

  ChannelModel({
    required this.channelName,
    required this.methodName,
    required this.arguments,
    required this.type,
  }) : sendTimestamp = DateTime.now().millisecondsSinceEpoch;


  ChannelModel.error({
    required this.channelName,
    this.methodName = '',
    this.arguments = '',
    this.type = -1,
  }) : sendTimestamp = DateTime.now().millisecondsSinceEpoch;

  ///channel 名
  final String channelName;

  ///方法名
  final String? methodName;

  ///方法附带参数
  final dynamic arguments;

  ///方法调用时间
  final int sendTimestamp;

  ///channel类型
  /// * 见[TYPE_DEV_SEND]等
  final int type;

  ///结果接收时间
  int receiveTimestamp = 0;

  ///返回结果
  dynamic results;

  String get resStr => results.toString();

  MethodCodec? methodCodec;

  @override
  bool get isAbnormal => type == -1;

  @override
  Map<String, String> getPackage() => <String, String>{
    'channelName' : channelName,
    'methodName' : methodName ?? '',
    'sendTimestamp' : sendTimestamp.toString(),
    'arguments' : arguments.toString(),
    'receiveTimestamp' : receiveTimestamp.toString(),
    //结果可能会较大，做一个截取
    'results' : resStr.length > 100 ? resStr.substring(0, 99) : resStr,
  };

}













