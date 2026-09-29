# ume_kit_memory_detector

自动以 Route 为单元，进行内存泄漏检测。（参赛作品）

## 使用

添加`UmeKitMemoryDetector`到`navigatorObservers`

```
      navigatorObservers: [
        UmeKitMemoryDetector(),
      ],

```

（非必须）将`MemoryDetectorButton` 添加到任意位置，建议悬浮窗：

```
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              entry = OverlayEntry(builder: (_) => const MemoryDetectorButton());
              Overlay.of(context)?.insert(entry!);
            });
```

默认通过`LeakedInfoDbRecorder`写入到数据库，并可以通过它来获取所存储的泄露信息。

```
	//其父类
	///泄露信息记录器
	abstract class LeakedInfoRecorder{

	  ///添加一条记录
	  void add(LeakedInfo info);

	  ///批量添加记录
	  void addAll(List<LeakedInfo> list);

	  ///根据id删除一条记录
	  void deleteById(int id);

	  ///清除所有记录
	  void clear();

	  ///获取所有记录
	  Future<List<LeakedInfo>> getAll();

	}
```

## 更多使用方式

### 信息流监听

可以直接监听`UmeKitMemoryDetector`的`stream`来获取检测阶段及泄漏信息：

```
    UmeKitMemoryDetector().taskPhaseStream.listen(...检测阶段...);

    UmeKitMemoryDetector().infoStream.listen(...泄漏信息...);
```

### 自定义对象检测

通过以下方法可以添加任意待检测对象：

```
	//key需要是唯一的
	//添加一个待检测对象
    UmeKitMemoryDetector().addObject(obj: leaker, group: key);
	...
	//开始检测
    UmeKitMemoryDetector().doDetect(key);
```

### 自定义泄露信息存储方式

默认通过 `LeakedInfoDbRecorder`写入到数据库，也可以覆盖`defaultHandler`来调整输出位置：

```
	LeakedRecordHandler defaultHandler = YourRecorder().add;
```

```
	class YourRecorder implements LeakedInfoRecorder{

	  ///添加一条记录
	  void add(LeakedInfo info);

	  ///批量添加记录
	  void addAll(List<LeakedInfo> list);

	  ///根据id删除一条记录
	  void deleteById(int id);

	  ///清除所有记录
	  void clear();

	  ///获取所有记录
	  Future<List<LeakedInfo>> getAll();

	}
```

### 自定义检测属性

可以通过以下字段，调整检测属性:

```
///引用链最大长度
/// * 见 [VmService.getRetainingPath]
const int maxRetainingPath = int.fromEnvironment("maxRetainingPath", defaultValue: 400);

///强制关闭内存检测
const bool closeMemDetector = bool.fromEnvironment("closeMemDetector", defaultValue: false);

///延迟检测
/// * 单位 : 毫秒
/// * 部分对象并不会及时回收
const int delayDoDetect = int.fromEnvironment('delayDoDetect', defaultValue: 800);

///扩展单元数量
/// * 在gc前创建[expandUnitNumber]个对象，用于触发full gc
/// * 0则不创建。
/// * 在实际项目接入中，由于项目所占用的内存，默认值可能过大，建议根据需求调整。
const int expandUnitNumber = int .fromEnvironment('expandUnitNumber', defaultValue: 10000000);
```

### 高度自定义

如果以上无法满足需求，可以直接继承`MemoryDetector`:

```
class YourCustomDetector extends MemoryDetector{
	//...your code
}
```
