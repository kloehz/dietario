/// Abstract local store. Implemented by `app_database_io.dart` (sqflite)
/// and `app_database_web.dart` (in-memory).
abstract class LocalStore {
  Future<void> open();
  Future<void> close();
  Future<void> clear(String table);

  Future<List<Map<String, Object?>>> queryAll(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  });

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]);

  Future<int> insertRow(String table, Map<String, Object?> values);
  Future<int> updateWhere(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  );
  Future<int> deleteWhere(
    String table,
    String where,
    List<Object?> whereArgs,
  );

  Future<void> replaceAll(
    String table,
    List<Map<String, Object?>> rows,
  );

  Future<int> upsertByRemoteId(
    String table,
    Map<String, Object?> row,
  );

  Future<void> deleteByRemoteId(String table, String remoteId);

  Future<void> setRemoteId(String table, int id, String remoteId);
}

/// Default (fallback) implementation factory. Real implementations live
/// in `app_database_io.dart` / `app_database_web.dart`, selected via
/// conditional import in `app_database.dart`.
LocalStore createLocalStore() => throw UnsupportedError(
      'No local store implementation was selected. '
      'Conditional import must supply one.',
    );
