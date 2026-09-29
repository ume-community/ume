# ume_kit_channel_observer

用于记录`platform channel `最近的调用记录,并支持显示的提示可能由于`native`通信所导致的`type error`异常。

## 使用

\*\*

下方使用方式，主要针对日常情况下，对项目中`native`通信过程所导致的类型转换错误的监控和调用记录的展示。

由于在中大型项目中，和 native 的通信复杂且由于 native 端可能由不同人/项目组 维护，所以在测试时并不能全路径覆盖，且`Flutter`的异常并非阻断式，所以没有显示的提示情况下，很难及时发现。故，通过增加悬浮窗及监听的方式(也可以扩展上报到日志服务器),在测试组测试时，显式的通知测试同学。

\*\*

在`main`函数中添加如下方法：

```
		void main() {
		  UmeKitChannelObserver.customZone(const YourRootWwidget());
		}
```

（非必须）将`ChannelObserverWidget` 添加到任意位置，建议悬浮窗：

```
                OverlayEntry entry = OverlayEntry(builder: (_) => const ChannelObserverWidget());
                Overlay.of(context)?.insert(entry);
```

## 更多使用方式

Tip: 如果不使用`UmeKitChannelObserver`的`customZone`或`runApp`方法，那么，下方的功能将失效。 即，需要你自行实现并混入`ChannelObserverServicesBinding`。具体可见代码实现方式。

### 导出最近调用记录

该模块核心功能主要是`native channel`的调用记录。
所以可以通过`UmeKitChannelObserver.getBindingInstance().popChannelRecorders()`拉取最近的调用记录，用作它用。

### 现有项目中直接混入 ChannelObserverServicesBinding

此外`UmeKitChannelObserver`的`customZone` 和 `runApp` 两个方法并非必须使用，如果项目中有类似的自定义，也可以直接混入`ChannelObserverServicesBinding` 或者仿照代码，做自定义更改。

### 处理 zone 内的 error

1.

```
///zone的error处理方法
/// * 可以覆盖此方法，然后自处理相关错误
/// * PS. 如果覆盖[zoneErrorHandler],将导致[UmeKitChannelObserver._errorStreamController]
/// * 、[ChannelObserverWidget]的失效。
ZoneErrorHandler zoneErrorHandler = UmeKitChannelObserver._defaultErrorHandler;
```

2.

对`UmeKitChannelObserver.errorStream` 监听

```
class UmeKitChannelObserver {

  ///用于控制zone内error的上报
  /// * 基于[customZone] 和 [runApp]的实现。
  static final StreamController<ErrorPackage> _errorStreamController = StreamController.broadcast();

  ///zone error sink
  static StreamSink<ErrorPackage> get errorSink => _errorStreamController.sink;

  ///zone error stream
  /// * 可以监听[errorStream]获取错误信息。
  static Stream<ErrorPackage> get errorStream => _errorStreamController.stream;



  //...other code

  }

```
