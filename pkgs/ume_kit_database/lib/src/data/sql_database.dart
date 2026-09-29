import 'package:ume_kit_database/src/data/databases.dart';
import 'package:sqflite/sqflite.dart';

///sqlite database update need conditions
/// db is sqlite database
/// the example is incomplete!!
///
/// db.insert('test', {"table_name": "ume", "table_size": 12,'tid':1});
///  db.insert('test', {"table_name": "ume", "table_size": 12,"tid":2});
/// }, updateMap: [
/// {   'test':
///         SqliteUpdateConditions(updateNeedWhere: 'tid = ?', updateNeedColumnKey: ['tid'])
///  }
///
class SqliteUpdateConditions implements UpdateConditions {
  SqliteUpdateConditions(
      {required this.updateNeedWhere, required this.updateNeedColumnKey});

  /// ```
  /// custom update
  /// int count = await db.update(tableTodo, todo.toMap(),
  ///    where: '$updateNeedWhere = ?', whereArgs: [map[updateNeedColumnKey]]);
  /// ```
  final String updateNeedWhere;

  /// all column are immutable
  final List<String> updateNeedColumnKey;

  @override
  String get getUpdateNeedWhere => updateNeedWhere;

  @override
  List<String> get getUpdateNeedColumnKey => updateNeedColumnKey;
}

class SqliteDatabase implements UMEDatabase {
  Database? db;
  SqliteDatabase(this._databaseName,
      {this.path,
      this.isDeleteDB = true,
      this.onConfigure,
      this.onCreate,
      this.onDowngrade,
      this.onUpgrade,
      this.onOpen,
      this.updateMap = const []});
  bool isDeleteDB;
  String? path;
  OnDatabaseConfigureFn? onConfigure;
  OnDatabaseCreateFn? onCreate;
  OnDatabaseVersionChangeFn? onUpgrade;
  OnDatabaseVersionChangeFn? onDowngrade;
  OnDatabaseOpenFn? onOpen;
  // key is table
  List<Map<TableName, SqliteUpdateConditions>> updateMap;
  final String _databaseName;
  @override
  String get databaseName => _databaseName;
  @override
  String? get databasePath => path;

  @override
  bool deleteDB() {
    return isDeleteDB;
  }
}

/// sqlite data
class SqliteTableData implements TableData {
  SqliteTableData(this._tableName,
      {this.createSql,
      this.rootPage = 0,
      this.name,
      this.type,
      required this.columnData});
  final String _tableName;
  final String? createSql;
  final int rootPage;
  final String? type;
  final String? name;
  final List<SqliteTableColumData> columnData;

  @override
  String tableName() {
    return _tableName;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Table_Name": _tableName,
      "Create_SQL": createSql,
      "rootpage": rootPage,
      "type": type,
      "name": name,
      "Table_Colum": columnData.map((e) => e.columnName()).toList()
    };
  }
}

class SqliteTableColumData implements ColumnData {
  SqliteTableColumData(
      {required this.cid,
      required this.defaultValue,
      required this.type,
      required this.name,
      required this.notNull,
      required this.pk});

  final int cid;
  final String name;
  final String type;
  final int? pk;
  final int? notNull;
  final dynamic defaultValue;

  @override
  String columnName() {
    return name;
  }
}
