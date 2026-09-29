import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'leak_info.dart';
import 'package:sqflite/sqflite.dart';

///数据库版本号
const int _kLeakedInfoDatabase =
    int.fromEnvironment('leakedInfoDatabase', defaultValue: 1);

///表字段
class _LeakedRecordTable {
  static const String name = 'leak_record_table';
  static const String id = '_id';
  static const String leakedPathJson = 'leakPath';
  static const String gcType = 'gcType';
}

class _DataBaseBridge {
  static Future<Database> _openDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'memory_leak_record.db'),
        version: _kLeakedInfoDatabase, onCreate: (Database db, int version) {
      return db.execute('CREATE TABLE IF NOT EXISTS ${_LeakedRecordTable.name}('
          '${_LeakedRecordTable.id} TEXT NOT NULL PRIMARY KEY, '
          '${_LeakedRecordTable.gcType} TEXT, '
          '${_LeakedRecordTable.leakedPathJson} TEXT)');
    });
  }
}

///数据库记录器
class LeakedInfoDbRecorder implements LeakedInfoRecorder {
  static LeakedInfoDbRecorder? _instance;

  factory LeakedInfoDbRecorder() {
    _instance ??= LeakedInfoDbRecorder._();
    return _instance!;
  }

  LeakedInfoDbRecorder._();

  Future<Database> get database => _DataBaseBridge._openDatabase();

  ///转换实体
  Future<LeakedInfo> _transform2ripe(Map<String, dynamic> raw) async {
    final String timeStamp = raw[_LeakedRecordTable.id];
    final String gcType = raw[_LeakedRecordTable.gcType];
    final String path = raw[_LeakedRecordTable.leakedPathJson];
    final datas = await compute(json.decode, path);
    return LeakedInfo(
        datas.map((json) => RetainingNode.fromJson(json)).toList(), gcType,
        timestamp: int.tryParse(timeStamp));
  }

  ///转换记录
  Map<String, dynamic> _transform2Raw(LeakedInfo info) {
    return {
      _LeakedRecordTable.id: info.timestamp.toString(),
      _LeakedRecordTable.gcType: info.gcRootType,
      _LeakedRecordTable.leakedPathJson: info.retainingPathJson
    };
  }

  Future<void> _insert(LeakedInfo info) async {
    final db = await database;
    await db.insert(_LeakedRecordTable.name, _transform2Raw(info),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _insertAll(List<LeakedInfo> info) async {
    List<Future> futures = info.map<Future>((e) => _insert(e)).toList();
    await Future.wait(futures);
  }

  Future<List<LeakedInfo>> _queryAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_LeakedRecordTable.name);
    final stream = Stream.fromIterable(maps).asyncMap(_transform2ripe);
    return (await stream.toList());
  }

  Future<void> _deleteById(int id) async {
    final db = await database;
    await db.delete(_LeakedRecordTable.name,
        where: '${_LeakedRecordTable.id} = ?', whereArgs: [id.toString()]);
  }

  Future<void> _deleteAll() async {
    await (await database).delete(_LeakedRecordTable.name);
  }

  @override
  void add(LeakedInfo info) => _insert(info);

  @override
  void addAll(List<LeakedInfo> list) => _insertAll(list);

  @override
  void clear() => _deleteAll();

  @override
  void deleteById(int id) => _deleteById(id);

  @override
  Future<List<LeakedInfo>> getAll() => _queryAll();
}

///泄露信息记录器
abstract class LeakedInfoRecorder {
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
