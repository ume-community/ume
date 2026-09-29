import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'leak_info.dart';

import 'leaked_info_recorder.dart';

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import 'ume_kit_memory_detector.dart';

/// 作者：李佳奇
/// 日期：2022/4/18
/// 备注：内存检测类

typedef LeakedRecordHandler = void Function(LeakedInfo info);

///泄露数据默认处理器
/// * 如果需要自行处理，可以替换这个变量
/// * 如果只是分流处理，可以监听[MemoryDetector.infoStream]
LeakedRecordHandler defaultHandler = LeakedInfoDbRecorder().add;

abstract class MemoryDetector with VmServiceDelegate, DetectTaskRunner {
  ///[forceClose] = true : 禁用整个检测功能
  ///[autoTask] 默认false，实际项目中一些常存页面会导致检测时间过长
  MemoryDetector(this._isDetectorClose, {bool autoTask = false}) {
    if (!kReleaseMode && !_isDetectorClose) {
      _warmRunnerUp();
      if (autoTask) {
        taskPhaseStream.listen(_autoTaskListener);
      }
    }
  }

  ///关闭检测
  bool _isDetectorClose;

  ///泄露信息流
  Stream<LeakedInfo?> get infoStream => _infoStreamController.stream;

  ///检测机运行状态
  Stream<DetectTaskEvent> get taskPhaseStream => _detectEventController.stream;

  TaskPhase get currentPhase => _currentPhase;

  ///检测功能开关
  void switchDetector(bool on) {
    _isDetectorClose = on;
  }

  ///检测任务完成会，会自动检测下一个
  void _autoTaskListener(DetectTaskEvent event) {
    if (event.phase == TaskPhase.endDetect) {
      _startDetectTask();
    }
  }

  ///添加一个待检测对象，并触发检测
  /// * [obj] 待检测对象， [group]所属分组
  void addObjectWithDetect({required Object obj, required String group}) {
    if (_isDetectorClose) return;
    _addDetectObject(obj: obj, group: group);
    _startDetectTask();
  }

  ///添加检测对象
  void addObject({required Object obj, required String group}) {
    if (_isDetectorClose) return;
    _addDetectObject(obj: obj, group: group);
  }

  void doDetect(String group) {
    if (_isDetectorClose) return;
    _startDetectTask(group: group);
  }
}

void logFence() =>
    debugPrint("=================MEMORY DETECTOR ERROR=================");

const String _memDetectorPath =
    'package:ume_kit_memory_detector/memory_detector.dart';

int _objKey = 0;

Map<String, dynamic> _objCache = {};

///生成key
String generateNewObjKey() => '${++_objKey}';

///根据key获取对应obj
dynamic key2Obj(String key) => _objCache[key];

///检测任务执行状态
/// * 一般检测任务顺序为自上到下，即: [TaskPhase.startDetect] -> ... -> [TaskPhase.endDetect]
enum TaskPhase {
  startDetect,
  startGC,
  endGC,
  startAnalyze,
  endAnalyze,
  endDetect,
}

class DetectTaskEvent {
  DetectTaskEvent({required this.timeStamp, required this.phase});

  DetectTaskEvent.withTimeStamp(this.phase)
      : timeStamp = DateTime.now().millisecondsSinceEpoch;

  final int timeStamp;

  final TaskPhase phase;
}

mixin DetectTaskRunner on VmServiceDelegate {
  ///待检测队列
  final SplayTreeMap<String, Expando> _detectTaskQueue = SplayTreeMap();

  ///泄露信息产出
  final StreamController<LeakedInfo> _infoStreamController =
      StreamController.broadcast();

  ///检测状态
  final StreamController<DetectTaskEvent> _detectEventController =
      StreamController.broadcast();

  StreamSink<DetectTaskEvent> get _sink => _detectEventController.sink;

  StreamSink<LeakedInfo> get _infoSink => _infoStreamController.sink;

  bool get isRunnerIdle => _currentPhase == TaskPhase.endDetect;

  TaskPhase _currentPhase = TaskPhase.endDetect;

  ///当前处理的对象
  Expando? _currentTask;

  ///是否已预热
  bool warmedUp = false;

  ///预热任务执行器
  void _warmRunnerUp() {
    if (warmedUp) return;
    warmedUp = true;
    _detectEventController.stream.listen(_runnerListener);
    _infoStreamController.stream.listen(defaultHandler);
  }

  void _runnerListener(DetectTaskEvent event) {
    _currentPhase = event.phase;
  }

  ///添加检测对象
  void _addDetectObject({required Object obj, required String group}) {
    _checkType(obj);
    Expando? expando = _detectTaskQueue[group];
    expando ??= Expando('ephemeron$group');
    expando[obj] = true;
    _detectTaskQueue[group] = expando;
  }

  ///开始检测
  /// * 可指定 group检测，也可以默认从第一个检测
  void _startDetectTask({String? group}) {
    if (isRunnerIdle && _detectTaskQueue.isNotEmpty) {
      _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.startDetect));
      String? f = group ?? _detectTaskQueue.firstKey();
      _currentTask = _detectTaskQueue.remove(f);
      if (_currentTask != null) {
        _doDetectTask();
      } else {
        _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.endDetect));
      }
    }
  }

  ///执行检测
  /// * 调用入口为[_startDetectTask]
  void _doDetectTask({int delay = delayDoDetect}) {
    Timer(Duration(milliseconds: delay), () async {
      if (await _checkHasLeaked(_currentTask!)) {
        _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.startGC));
        await compute(_expandHeap, expandUnitNumber, debugLabel: 'expand heap');
        await _startGC();
        _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.endGC));
        _startAnalyzeAfterGc();
      } else {
        _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.endDetect));
      }
    });
  }

  ///gc完成后开始分析泄露
  void _startAnalyzeAfterGc() async {
    List<dynamic> weakPropertyList = await _getPropertyList(_currentTask!);
    _currentTask = null;
    for (var weakProperty in weakPropertyList) {
      if (weakProperty != null) {
        final leakedInstance = await _getInstanceRefByKey(weakProperty.id);
        if (leakedInstance != null) {
          _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.startAnalyze));
          LeakedInfo? leakedInfo = await compute(LeakAnalyzer.analyze,
              RawLeakNode(leakedInstance, maxRetainingPath),
              debugLabel: 'memory analyze');
          _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.endAnalyze));
          if (leakedInfo != null) {
            _infoSink.add(leakedInfo);
          }
          _sink.add(DetectTaskEvent.withTimeStamp(TaskPhase.endDetect));
        }
      }
    }
  }

  ///检查是否泄露
  Future<bool> _checkHasLeaked(Expando expando) async {
    final List<dynamic> weakPropertyList = await _getPropertyList(expando);
    for (var p in weakPropertyList) {
      if (p != null) {
        final leaker = await _getInstanceRefByKey(p.id);
        if (leaker != null) {
          return true;
        }
      }
    }
    return false;
  }

  ///获取引用链
  Future<List<dynamic>> _getPropertyList(Expando expando) async {
    if (await hasVmService) {
      final data =
          (await _getInstanceByObj(expando))?.getFieldValueInstance('_data');
      if (data?.id != null) {
        final dataObj = await _getObjInstanceById(data.id);
        if (dataObj?.json != null) {
          return Instance.parse(dataObj!.json)?.elements ?? [];
        }
      }
    }
    return [];
  }

  ///获取对象引用
  Future<InstanceRef?> _getInstanceRefByKey(String weakPropertyKey) async {
    final weakProperyObj = await _getObjInstanceById(weakPropertyKey);
    if (weakProperyObj != null) {
      // [Original]: Instance.parse(weakProperyObj.json)?.propertyKey;
      return Instance.parse(weakProperyObj.json);
    }

    return null;
  }

  void _checkType(object) {
    if ((object == null) ||
        (object is bool) ||
        (object is num) ||
        (object is String) ||
        (object is Pointer) ||
        (object is Struct)) {
      throw ArgumentError.value(object,
          "Expandos are not allowed on strings, numbers, booleans, null, Pointers, Structs or Unions.");
    }
  }
}

mixin VmServiceDelegate {
  Uri? _observatoryUri;

  VmService? _vmService;

  VM? _vm;

  Future<bool> get hasVmService async => (await _getVmService()) != null;

  Future<VM?> _getVM() async {
    _vm ??= await (await _getVmService())?.getVM();
    return _vm;
  }

  Future<VmService?> _getVmService() async {
    if (_vmService == null) {
      final Uri? uri = await _getServerUri();
      if (uri != null) {
        _vmService = await vmServiceConnectUri(uri.toString()).catchError((e) {
          if (e is SocketException) {
            logFence();
            //dds is enable
            debugPrint('vm_service connection refused, Try:');
            debugPrint(
                'run \'flutter run\' with --disable-dds to disable dds.');
          }
        });
      }
    }
    return _vmService;
  }

  ///获取 vm server的uri
  Future<Uri?> _getServerUri() async {
    ServiceProtocolInfo info = await Service.getInfo();
    _observatoryUri = info.serverWebSocketUri;
    return _observatoryUri;
  }

  ///获取主线程
  Future<Isolate?> _getMainIsolate() async {
    final vm = await _getVM();
    if (vm != null) {
      final IsolateRef? ref =
          vm.isolates?.firstWhere((element) => element.name == 'main');

      final vms = await _getVmService();
      if (ref?.id != null) {
        return vms?.getIsolate(ref!.id!);
      }
    }
    return null;
  }

  ///开始gc
  Future _startGC() async {
    final vms = await _getVmService();
    if (vms != null) {
      final mainIso = await _getMainIsolate();
      if (mainIso != null && mainIso.id != null) {
        await vms.getAllocationProfile(mainIso.id!, gc: true);
      }
    }
  }

  ///根据[uri] 查找对应库
  Future<LibraryRef?> _getLibraryByUri(String uri) async {
    Isolate? mainIso = await _getMainIsolate();
    if (mainIso != null) {
      final libRefs = mainIso.libraries;
      if (libRefs != null) {
        return libRefs.firstWhere((lib) => lib.uri == uri);
      }
    }
    return null;
  }

  Future<String?> _getObjectId(dynamic obj) async {
    final detectorLib = await _getLibraryByUri(_memDetectorPath);
    if (detectorLib == null || detectorLib.id == null) return null;

    final vms = await _getVmService();
    if (vms == null) return null;

    final mainIso = await _getMainIsolate();
    if (mainIso == null || mainIso.id == null) return null;

    Response keyRes =
        await vms.invoke(mainIso.id!, detectorLib.id!, 'generateNewObjKey', []);
    final keyRef = InstanceRef.parse(keyRes.json);
    String? key = keyRef?.valueAsString;
    if (key == null) return null;
    _objCache[key] = obj;

    try {
      Response objRes = await vms
          .invoke(mainIso.id!, detectorLib.id!, 'key2Obj', [keyRef!.id!]);
      final objRef = Instance.parse(objRes.json);
      return objRef?.id;
    } catch (e) {
      logFence();
      debugPrint('getObjectId error : \n $e');
    } finally {
      _objCache.remove(key);
    }
    return null;
  }

  ///根据[objId] 获取[Obj]
  Future<Obj?> _getObjInstanceById(String objId) async {
    final vms = await _getVmService();
    if (vms != null) {
      final mainIso = await _getMainIsolate();
      if (mainIso != null && mainIso.id != null) {
        try {
          Obj obj = await vms.getObject(mainIso.id!, objId);
          return obj;
        } catch (e) {
          logFence();
          debugPrint('getObjInstanceById error : \n $e');
        }
      }
    }
    return null;
  }

  ///根据[Obj] 获取[Instance]
  Future<Instance?> _getInstanceByObj(dynamic obj) async {
    final vms = await _getVmService();
    if (vms != null) {
      final mainIso = await _getMainIsolate();
      if (mainIso != null && mainIso.id != null) {
        try {
          final objId = await _getObjectId(obj);
          if (objId != null) {
            Obj obj = await vms.getObject(mainIso.id!, objId);
            return Instance.parse(obj.json);
          }
        } catch (e) {
          logFence();
          debugPrint('getInstanceByObj error : \n $e');
        }
      }
    }
    return null;
  }

  ///获取引用路径
  /// * [objId] 目标对象id
  /// * [limit] 引用路径最大长度
  Future<RetainingPath?> _getRetainingPath(String objId, int limit) async {
    final vms = await _getVmService();
    if (vms != null) {
      final mainIso = await _getMainIsolate();
      if (mainIso != null && mainIso.id != null) {
        return vms.getRetainingPath(mainIso.id!, objId, limit);
      }
    }
    return null;
  }

  ///执行库房方法
  /// * [targetId] 目标库
  /// * [method] 方法
  /// * [argumentIds] 参数
  Future<String?> _invokeMethod(
      String targetId, String method, List<String> argumentIds) async {
    final vms = await _getVmService();
    if (vms != null) {
      final mainIso = await _getMainIsolate();
      if (mainIso != null && mainIso.id != null) {
        try {
          Response res =
              await vms.invoke(mainIso.id!, targetId, method, argumentIds);
          return Instance.parse(res.json)?.valueAsString;
        } catch (e) {
          logFence();
          debugPrint("_invokeMethod error : \n $e");
        }
      }
    }
    return null;
  }

//检测问题
//bool isolateAvaliable(Isolate? isolate) => isolate != null && isolate.id != null;
}

class LeakAnalyzer with VmServiceDelegate {
  static LeakAnalyzer? _analyzer;

  final Map<String, ObjectAnalyzeStrategy> _parser = {
    '@Field': FieldRefParser(),
    '@Instance': InstanceRefParser(),
    'default': DefaultRefParser(),
  };

  ObjectAnalyzeStrategy _getParser(String flag) =>
      _parser[flag] ?? _ExceptionParser();

  /// The type of GC root which is holding a reference to the specified object.
  /// Possible values include:  * class table  * local handle  * persistent
  /// handle  * stack  * user global  * weak persistent handle  * unknown
  ///
  /// run on subIsolate
  static Future<LeakedInfo?> analyze(RawLeakNode node) async {
    _analyzer ??= LeakAnalyzer();
    final leakedInstance = node.leakedInstance;
    final maxRetainingPath = node.maxRetainingPath;
    if (leakedInstance?.id != null) {
      final retainingPath = await _analyzer!
          ._getRetainingPath(leakedInstance!.id!, maxRetainingPath);
      if (retainingPath?.elements != null &&
          retainingPath!.elements!.isNotEmpty) {
        final retainingObjectList = retainingPath.elements!;
        final stream = Stream.fromIterable(retainingObjectList)
            .asyncMap(_analyzeObject2Node);
        List<RetainingNode> retainingPathList = [];
        for (var element in (await stream.toList())) {
          if (element != null) {
            retainingPathList.add(element);
          }
        }
        return LeakedInfo(retainingPathList, retainingPath.gcRootType);
      }
    }
    return null;
  }

  static Future<RetainingNode?> _analyzeObject2Node(
      RetainingObject object) async {
    if (object.value is InstanceRef || object.value is FieldRef) {
      return _analyzer!
          ._getParser(object.value!.type)
          .analyzeObject2Node(_analyzer!, object);
    } else if (object.value?.type != '@Context') {
      return _analyzer!
          ._getParser('default')
          .analyzeObject2Node(_analyzer!, object);
    }
    return null;
  }

  static Future<ClosureInfo?> _getClosureInfo(Instance? instance) async {
    if (instance != null && instance.kind == 'Closure') {
      final name = instance.closureFunction?.name;
      final owner = instance.closureFunction?.owner;
      final info =
          ClosureInfo(closureFunctionName: name, closureOwner: owner?.name);
      await _getClosureOwnerInfo(owner, info);
      return info;
    }
    return null;
  }

  static Future _getClosureOwnerInfo(dynamic ref, ClosureInfo info) async {
    if (ref?.id != null) {
      if (ref is LibraryRef) {
        Library? library =
            (await _analyzer!._getObjInstanceById(ref.id!)) as Library?;
        info.libraries = library?.uri;
      } else if (ref is ClassRef) {
        Class? clz = (await _analyzer!._getObjInstanceById(ref.id!)) as Class?;
        info.closureOwnerClass = clz?.name;
        info.libraries = clz?.library?.uri;
      } else if (ref is FuncRef) {
        if (info.funLine == null) {
          Func? func = (await _analyzer!._getObjInstanceById(ref.id!)) as Func?;
          if (func?.location?.script?.id != null) {
            Script? script = (await _analyzer!
                ._getObjInstanceById(func!.location!.script!.id!)) as Script?;
            if (script != null && func.location?.tokenPos != null) {
              info.funLine =
                  script.getLineNumberFromTokenPos(func.location!.tokenPos!);
              info.funColumn =
                  script.getColumnNumberFromTokenPos(func.location!.tokenPos!);
            }
          }
        }
        await _getClosureOwnerInfo(ref.owner, info);
      }
    }
  }

  ///输出map
  static Future<String?> _map2String(RetainingObject retainingObject) async {
    String? keyString;
    if (retainingObject.parentMapKey?.id != null) {
      Obj? keyObj = await _analyzer!
          ._getObjInstanceById(retainingObject.parentMapKey!.id!);
      if (keyObj?.json != null) {
        Instance? keyInstance = Instance.parse(keyObj!.json!);
        if (keyInstance != null &&
            (keyInstance.kind == 'String' ||
                keyInstance.kind == 'Int' ||
                keyInstance.kind == 'Double' ||
                keyInstance.kind == 'Bool')) {
          keyString = '${keyInstance.kind}: \'${keyInstance.valueAsString}\'';
        } else {
          if (keyInstance?.id != null) {
            keyString =
                'Object: class=${keyInstance?.classRef?.name}, ${await _analyzer!._invokeMethod(keyInstance!.id!, 'toString', [])}';
          }
        }
      }
    }
    return keyString;
  }

  ///获取源码位置
  static Future<SourceCodeLocation?> _getSourceCodeLocation(
      String? parentField, Class clz) async {
    SourceCodeLocation? location;
    if (parentField != null && clz.name != '_Closure') {
      List? filedAndClass = await _getFieldAndClassByName(
          clz, Uri.encodeQueryComponent(parentField));
      if (filedAndClass != null) {
        FieldRef fieldRef = filedAndClass.first;
        ClassRef classRef = filedAndClass.last;
        if (fieldRef.id != null) {
          Field? field =
              (await _analyzer!._getObjInstanceById(fieldRef.id!)) as Field?;
          if (field != null) {
            //get field's Script info, source code, line number, clounm number
            Script? script = (await _analyzer!
                ._getObjInstanceById(field.location!.script!.id!)) as Script?;
            if (script != null && field.location?.tokenPos != null) {
              int? line =
                  script.getLineNumberFromTokenPos(field.location!.tokenPos!);
              int? column =
                  script.getColumnNumberFromTokenPos(field.location!.tokenPos!);
              String? codeLine = script.source
                  ?.substring(
                      field.location!.tokenPos!, field.location!.endTokenPos!)
                  .split('\n')
                  .first;
              // final StringBuffer buffer = StringBuffer();
              // List<String> lines = script.source?.substring(field.location!.tokenPos!).split('\n') ?? [];
              // int limit = 3;
              // for (var element in lines) {
              //   if(limit <= 0) break;
              //   buffer.write(element);
              //   limit--;
              // }
              location = SourceCodeLocation(codeLine, line, column,
                  classRef.name, classRef.library?.uri, '');
            }
          }
        }
      }
    }
    return location;
  }

  ///根据name 获取field和class
  /// * return List : 0-> filedRef , 1-> classRef
  static Future<List?> _getFieldAndClassByName(Class? clz, String name) async {
    if (clz?.fields == null) return null;
    for (var f in clz!.fields!) {
      if (f.id != null && f.name!.endsWith(name)) {
        return [f, Class.parse(clz.json)];
      }
    }
    //has father
    if (clz.superClass?.id != null) {
      Class? superClz =
          (await _analyzer!._getObjInstanceById(clz.superClass!.id!)) as Class?;
      return _getFieldAndClassByName(superClz, name);
    }
    return null;
  }

  ///获取对象类型
  static Future<LeakedNodeType> _getObjectType(Class? clazz) async {
    if (clazz?.name == null) return LeakedNodeType.unknown;
    if (clazz!.name == 'Widget') {
      return LeakedNodeType.widget;
    } else if (clazz.name == 'Element') {
      return LeakedNodeType.element;
    }
    if (clazz.superClass?.id != null) {
      Class? superClass = (await _analyzer!
          ._getObjInstanceById(clazz.superClass!.id!)) as Class?;
      return _getObjectType(superClass);
    } else {
      return LeakedNodeType.unknown;
    }
  }
}

///解析器

class DefaultRefParser implements ObjectAnalyzeStrategy {
  @override
  Future<RetainingNode?> analyzeObject2Node(
      LeakAnalyzer analyzer, RetainingObject object) {
    return Future.value(RetainingNode(object.value?.type ?? '',
        parentField: object.parentField.toString()));
  }
}

class FieldRefParser implements ObjectAnalyzeStrategy {
  @override
  Future<RetainingNode?> analyzeObject2Node(
      LeakAnalyzer analyzer, RetainingObject object) async {
    FieldRef fieldRef = object.value as FieldRef;
    final String name = fieldRef.name ?? '';

    Class? clz;
    if (fieldRef.owner?.id != null) {
      var result = await analyzer._getObjInstanceById(fieldRef.owner!.id!);
      if (result is Class?) {
        clz = result;
      }
    }

    SourceCodeLocation? sourceCodeLocation;
    if (fieldRef.name != null && clz != null) {
      sourceCodeLocation =
          await LeakAnalyzer._getSourceCodeLocation(fieldRef.name, clz);
    }

    String? toString;
    if (fieldRef.id != null) {
      toString = await analyzer._invokeMethod(fieldRef.id!, 'toString', []);
    }

    String? keyInfo = await LeakAnalyzer._map2String(object);

    ClosureInfo? closureInfo;
    if (object.value!.json != null) {
      closureInfo = await LeakAnalyzer._getClosureInfo(
          Instance.parse(object.value!.json!));
    }

    return RetainingNode(
      name,
      parentField: object.parentField?.toString(),
      parentIndex: object.parentListIndex,
      parentKey: keyInfo,
      libraries: clz?.library?.uri,
      sourceCodeLocation: sourceCodeLocation,
      closureInfo: closureInfo,
      string: toString,
      leakedNodeType: LeakedNodeType.field,
    );
  }
}

class InstanceRefParser implements ObjectAnalyzeStrategy {
  @override
  Future<RetainingNode?> analyzeObject2Node(
      LeakAnalyzer analyzer, RetainingObject object) async {
    InstanceRef instanceRef = object.value as InstanceRef;
    final String name = instanceRef.classRef?.name ?? '';

    Class? clz;
    if (instanceRef.classRef?.id != null) {
      clz = (await analyzer._getObjInstanceById(instanceRef.classRef!.id!))
          as Class?;
    }

    SourceCodeLocation? sourceCodeLocation;
    if (object.parentField != null && clz != null) {
      sourceCodeLocation =
          await LeakAnalyzer._getSourceCodeLocation(object.parentField!, clz);
    }

    String? toString;
    if (instanceRef.id != null) {
      toString = await analyzer._invokeMethod(instanceRef.id!, 'toString', []);
    }

    String? keyInfo = await LeakAnalyzer._map2String(object);

    ClosureInfo? closureInfo;
    if (object.value!.json != null) {
      closureInfo = await LeakAnalyzer._getClosureInfo(
          Instance.parse(object.value!.json!));
    }

    return RetainingNode(
      name,
      parentField: object.parentField?.toString(),
      parentIndex: object.parentListIndex,
      parentKey: keyInfo,
      libraries: clz?.library?.uri,
      sourceCodeLocation: sourceCodeLocation,
      closureInfo: closureInfo,
      string: toString,
      leakedNodeType: await LeakAnalyzer._getObjectType(clz),
    );
  }
}

class _ExceptionParser implements ObjectAnalyzeStrategy {
  @override
  Future<RetainingNode?> analyzeObject2Node(
      LeakAnalyzer analyzer, RetainingObject object) {
    throw Exception('_ExceptionParser : maybe caused by wrong key.');
  }
}

abstract class ObjectAnalyzeStrategy {
  Future<RetainingNode?> analyzeObject2Node(
      LeakAnalyzer analyzer, RetainingObject object);
}

extension DetectInstance on Instance {
  BoundField? getField(String name) {
    if (fields != null) {
      return fields!.firstWhere((f) => f.decl?.name == name);
    }
    return null;
  }

  dynamic getFieldValueInstance(String name) => getField(name)?.value;
}

void _expandHeap(int size) {
  debugPrint('expanding...');
  List.generate(size, (index) => HashMap());
  debugPrint('expanded');
}
