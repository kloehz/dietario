// Local persistence facade. Picks the right backend by conditional
// import so mobile/desktop get sqflite and web gets an in-memory store
// (the app is always online via Supabase on web, so no local cache needed).
import 'app_database_backend.dart'
    if (dart.library.io) 'app_database_io.dart'
    if (dart.library.js_interop) 'app_database_web.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  LocalStore? _store;

  Future<LocalStore> get _backend async {
    if (_store != null) return _store!;
    _store = createLocalStore();
    await _store!.open();
    return _store!;
  }

  Future<void> close() async {
    await _store?.close();
    _store = null;
  }

  // ---- Generic helpers (used by repos for sync operations) ----

  Future<void> replaceAll(
    String table,
    List<Map<String, Object?>> rows,
  ) async {
    await (await _backend).replaceAll(table, rows);
  }

  Future<int> upsertByRemoteId(
    String table,
    Map<String, Object?> row,
  ) async {
    return (await _backend).upsertByRemoteId(table, row);
  }

  Future<void> deleteByRemoteId(String table, String remoteId) async {
    await (await _backend).deleteByRemoteId(table, remoteId);
  }

  Future<void> setRemoteId(String table, int id, String remoteId) async {
    await (await _backend).setRemoteId(table, id, remoteId);
  }

  Future<void> clearTable(String table) async {
    await (await _backend).clear(table);
  }

  // ---- Read helpers ----

  Future<List<Map<String, Object?>>> queryAll(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    return (await _backend).queryAll(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    return (await _backend).rawQuery(sql, args);
  }

  // ---- Write helpers ----

  Future<int> insertRow(String table, Map<String, Object?> values) async {
    return (await _backend).insertRow(table, values);
  }

  Future<int> updateWhere(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    return (await _backend).updateWhere(table, values, where, whereArgs);
  }

  Future<int> deleteWhere(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    return (await _backend).deleteWhere(table, where, whereArgs);
  }
}
