import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'model/package_model.dart';
import 'model/warehouse.dart';

export 'widget/channel_observer.dart';
export 'widget/recent_channel_record_page.dart';

typedef ZoneErrorHandler = void Function(Object error, StackTrace? stack);

///zone的error处理方法
/// * 可以覆盖此方法，然后自处理相关错误
/// * PS. 如果覆盖[zoneErrorHandler],将导致[UmeKitChannelObserver._errorStreamController]
/// * 、[ChannelObserverWidget]的失效。
ZoneErrorHandler zoneErrorHandler = UmeKitChannelObserver._defaultErrorHandler;

///platform channel 工具箱 用于记录最近的调用记录
/// * 支持release/debug
///
/// * [customZone] 和 [runApp] 两个方法并非必须使用，如果项目中
/// * 有类似的自定义，也可以直接混入[ChannelObserverServicesBinding]。
/// * 或者仿照代码，做自定义更改。
///
class UmeKitChannelObserver {
  ///用于控制zone内error的上报
  /// * 基于[customZone] 和 [runApp]的实现。
  static final StreamController<ErrorPackage> _errorStreamController =
      StreamController.broadcast();

  ///zone error sink
  static StreamSink<ErrorPackage> get errorSink => _errorStreamController.sink;

  ///zone error stream
  /// * 可以监听[errorStream]获取错误信息。
  static Stream<ErrorPackage> get errorStream => _errorStreamController.stream;

  ///自定义zone
  /// * 用于捕获zone内的异常
  static void customZone(
    Widget rootWidget, {
    bool debugUpload = true, //debug下依然上报（上报到测试环境）
    ZoneSpecification? zoneSpecification,
  }) {
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZonedGuarded<Future<void>>(() async {
      runApp(rootWidget);
    }, zoneErrorHandler, zoneSpecification: zoneSpecification);
    FlutterError.onError = (details) {
      Zone.current.handleUncaughtError(
          details.exception, details.stack ?? StackTrace.fromString('empty'));
    };
  }

  ///自定义[WidgetsFlutterBinding]
  /// * 用于混入[ChannelObserverServicesBinding]。
  static runApp(Widget app) {
    ChannelObserverBinding.ensureInitialized()
      // ignore: invalid_use_of_protected_member
      ..scheduleAttachRootWidget(app)
      ..scheduleWarmUpFrame();
  }

  ///获取自定义[ChannelObserverBinding]
  static ChannelObserverBinding? getBindingInstance() {
    if (WidgetsBinding.instance is ChannelObserverBinding) {
      return (WidgetsBinding.instance as ChannelObserverBinding);
    }
    return null;
  }

  ///处理zone内异常
  /// * 这里主要用于处理[TypeError]，以配合展示[ChannelObserverServicesBinding]的作用
  static void _defaultErrorHandler(Object error, StackTrace? stack) {
    errorSink.add(ErrorPackage(error, stackTrace: stack));
  }
}

///自定义[WidgetsFlutterBinding]
/// * 如果你的项目已经自定义，可以考虑直接混入[ChannelObserverServicesBinding]
class ChannelObserverBinding extends WidgetsFlutterBinding
    with ChannelObserverServicesBinding {
  static WidgetsBinding ensureInitialized() {
    // if (WidgetsBinding.instance == null) {
    ChannelObserverBinding();
    // }
    // return WidgetsBinding.instance!;
    return WidgetsBinding.instance;
  }
}

///channel表的记录最大长度
const int recorderSize = int.fromEnvironment('recorderSize', defaultValue: 10);

///最近platform channel调用记录
/// * 记录条数上限：[recorderSize]
/// * 可以实现[IStorage]并覆盖[channelRecorder]
IStorage<ChannelModel> channelRecorder = CommonStorage(maxCount: recorderSize);

mixin ChannelObserverServicesBinding on BindingBase, ServicesBinding {
  late BinaryMessengerProxy _proxy;

  ///弹出队列所有记录
  /// 顺序： [远...近]
  List<ChannelModel> popChannelRecorders() => _proxy.allRecorders;

  @override
  BinaryMessenger createBinaryMessenger() {
    _proxy = BinaryMessengerProxy(super.createBinaryMessenger());
    return _proxy;
  }
}

class BinaryMessengerProxy extends BinaryMessenger {
  BinaryMessengerProxy(this.origin);

  final BinaryMessenger origin;

  final MethodCodec codec = const StandardMethodCodec();

  IStorage<ChannelModel> get recorder => channelRecorder;

  List<ChannelModel> get allRecorders => recorder.getAll();

  ChannelModel _recordChannel(String name, ByteData? data, bool send) {
    ChannelModel model;
    try {
      final MethodCall call = codec.decodeMethodCall(data);
      model = ChannelModel(
          channelName: name,
          methodName: call.method,
          arguments: call.arguments,
          type: send
              ? ChannelModel.TYPE_DEV_SEND
              : ChannelModel.TYPE_DEV_RECEIVE);
    } catch (e) {
      model = ChannelModel.error(channelName: name);
    }
    model.methodCodec = codec;
    recorder.save(model);
    return model;
  }

  void _resolveResult(ChannelModel model, ByteData? result) {
    try {
      if (model.methodCodec != null) {
        model.results =
            model.methodCodec?.decodeEnvelope(result ?? ByteData(1));
        model.receiveTimestamp = DateTime.now().millisecondsSinceEpoch;
      } else {
        model.receiveTimestamp = DateTime.now().millisecondsSinceEpoch;
      }
    } catch (e) {
      debugPrint('Channel resolve exception : ${e.toString()}');
    }
    model.methodCodec = null;
  }

  @override
  Future<void> handlePlatformMessage(String channel, ByteData? data,
      PlatformMessageResponseCallback? callback) {
    return origin.handlePlatformMessage(channel, data, callback);
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) async {
    final ChannelModel model = _recordChannel(channel, message, true);
    if (model.isAbnormal) {
      return origin.send(channel, message);
    }
    final ByteData? result = await origin.send(channel, message);
    _resolveResult(model, result);
    return result;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    origin.setMessageHandler(channel, handler);
  }
}

class ErrorPackage {
  ErrorPackage(this.error, {this.stackTrace});

  final Object error;

  StackTrace? stackTrace;
}
