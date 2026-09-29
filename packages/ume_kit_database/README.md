# ume database plugin

这个插件用于 Sqlite 和 Hive 查看等相关功能
具体的使用在例子中可以查看

```dart
void main() async {
  var sqlDb = SqliteDatabase('test.db', path: null, isDeleteDB: true,
      onCreate: (db, index) {
    db.execute(
        'create table test (table_name text,table_size integer,tid integer,tid1 integer,tid2 integer)');
    db.execute('create table people (name text,age integer)');
    db.insert('people', {
      "name": "ume",
      "age": 12
    });
    db.insert('people', {
      "name":
          "ume",
      "age": 12
    });
    db.insert('people', {
      "name": "ume",
      "age": 12
    });
    db.insert('test', {
      "table_name": "ume",
      "table_size": 12,
      'tid': 1,
      'tid1': 1,
      'tid2': 1
    });
    db.insert('test', {"table_name": "ume", "table_size": 12, "tid": 2});
  }, updateMap: [
    {
      'test': SqliteUpdateConditions(
          updateNeedWhere: 'tid = ?', updateNeedColumnKey: ['tid'])
    }
  ]);

  ///register hive databases
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  var pBox = await Hive.openBox<Person>("people");
  pBox.put("p", Person(age: 12, name: 'ume'));
  pBox.put("p1", Person(age: 13, name: 'ume'));
  pBox.put("p1", Person(age: 13, name: 'ume'));
  pBox.put("p2", Person(age: 14, name: 'ume'));

  ///register debug plugin
  var hive = HiveDatabase([HiveBoxItem<Person>(name: 'people', box: pBox)]);

  PluginManager.instance.register(DatabasePanel(databases: [sqlDb, hive]));
  runApp(const UMEWidget(child: MyApp(), enable: true)); // 初始化
}
```

Sqlite 有几个比较重要的参数和提示：
如果没有 id 作为表的唯一参数，那么希望使用 SqliteUpdateConditions 作为更新条件，在 main 方法中可以看到例子

目前的问题：
Hive 数据库无法添加和修改数据
Sqlite 数据库可能还存在不完善的地方
