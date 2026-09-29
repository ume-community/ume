import 'package:flutter_test/flutter_test.dart';
import 'package:ume_kit_database/ume_kit_database.dart';

void main() {
  group('DatabasesItem', () {
    test('holds the values passed to its constructor', () {
      final item = DatabasesItem(
        DatabaseType.sqlite,
        name: 'app.db',
        path: '/tmp/app.db',
      );

      expect(item.databasesType, DatabaseType.sqlite);
      expect(item.name, 'app.db');
      expect(item.path, '/tmp/app.db');
    });

    test('allows a null path', () {
      final item = DatabasesItem(
        DatabaseType.sharedPreferences,
        name: 'prefs',
        path: null,
      );

      expect(item.databasesType, DatabaseType.sharedPreferences);
      expect(item.name, 'prefs');
      expect(item.path, isNull);
    });
  });

  group('DatabaseType', () {
    test('exposes the supported database backends', () {
      expect(DatabaseType.values, containsAll(<DatabaseType>[
        DatabaseType.sqlite,
        DatabaseType.hive,
        DatabaseType.sharedPreferences,
        DatabaseType.objectDB,
        DatabaseType.customDB,
      ]));
    });
  });
}
