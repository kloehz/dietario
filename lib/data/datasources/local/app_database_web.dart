import 'app_database_backend.dart';

export 'app_database_backend.dart' show LocalStore;

LocalStore createLocalStore() => _MemoryStore();

/// In-memory implementation. On web we always have Supabase behind us, so
/// the local cache only needs to live long enough for the current session.
class _MemoryStore implements LocalStore {
  final Map<String, List<Map<String, Object?>>> _tables = {};
  int _nextId = 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {
    _tables.clear();
    _nextId = 1;
  }

  @override
  Future<void> clear(String table) async {
    _tables[table] = [];
  }

  void _ensure(String table) {
    _tables.putIfAbsent(table, () => []);
  }

  int _allocId() => _nextId++;

  @override
  Future<List<Map<String, Object?>>> queryAll(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    _ensure(table);
    final list = _tables[table]!;
    final filtered =
        where == null ? list : list.where((r) => _match(r, where, whereArgs ?? const [])).toList();
    final sorted = orderBy == null ? filtered : _sort(filtered, orderBy);
    if (columns == null) return List.of(sorted);
    return sorted.map((row) {
      final out = <String, Object?>{};
      for (final c in columns) {
        if (row.containsKey(c)) out[c] = row[c];
      }
      return out;
    }).toList();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    final lower = sql.toLowerCase();
    final m = RegExp(r'from\s+(\w+)').firstMatch(lower);
    if (m != null && lower.contains('max(order_index)')) {
      final table = m.group(1)!;
      _ensure(table);
      var max = -1;
      for (final r in _tables[table]!) {
        final oi = r['order_index'];
        if (oi is int && oi > max) max = oi;
      }
      return [{'m': max}];
    }
    if (m != null && lower.contains('count(*)')) {
      final table = m.group(1)!;
      _ensure(table);
      final rows = _tables[table]!;
      final purchased = lower.contains("status = 'comprado'");
      return [
        {
          'c': purchased
              ? rows.where((row) => row['status'] == 'comprado').length
              : rows.length,
        }
      ];
    }
    return [];
  }

  @override
  Future<int> insertRow(
    String table,
    Map<String, Object?> values,
  ) async {
    _ensure(table);
    final id = _allocId();
    _tables[table]!.add({...values, 'id': id});
    return id;
  }

  @override
  Future<int> updateWhere(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    final list = _tables[table];
    if (list == null) return 0;
    var count = 0;
    for (var i = 0; i < list.length; i++) {
      if (_match(list[i], where, whereArgs)) {
        list[i] = {...list[i], ...values};
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> deleteWhere(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final list = _tables[table];
    if (list == null) return 0;
    final before = list.length;
    list.removeWhere((r) => _match(r, where, whereArgs));
    return before - list.length;
  }

  @override
  Future<void> replaceAll(
    String table,
    List<Map<String, Object?>> rows,
  ) async {
    _ensure(table);
    _tables[table] = [
      for (final row in rows) {...row, 'id': _allocId()},
    ];
  }

  @override
  Future<int> upsertByRemoteId(
    String table,
    Map<String, Object?> row,
  ) async {
    _ensure(table);
    final remoteId = row['remote_id'];
    final list = _tables[table]!;
    if (remoteId != null) {
      final i = list.indexWhere((r) => r['remote_id'] == remoteId);
      if (i >= 0) {
        final id = list[i]['id'] as int;
        list[i] = {...row, 'id': id};
        return id;
      }
    }
    final id = _allocId();
    list.add({...row, 'id': id});
    return id;
  }

  @override
  Future<void> deleteByRemoteId(String table, String remoteId) async {
    _tables[table]?.removeWhere((r) => r['remote_id'] == remoteId);
  }

  @override
  Future<void> setRemoteId(String table, int id, String remoteId) async {
    final list = _tables[table];
    if (list == null) return;
    final i = list.indexWhere((r) => r['id'] == id);
    if (i >= 0) list[i] = {...list[i], 'remote_id': remoteId};
  }

  // ---- SQL-ish helpers (the repos only use `col = ?` AND-chains) ----

  bool _match(
    Map<String, Object?> row,
    String where,
    List<Object?> args,
  ) {
    var i = 0;
    for (final part in where.split(' AND ')) {
      final eq = part.split('=');
      if (eq.length != 2) return false;
      final col = eq[0].trim();
      if (i >= args.length) return false;
      if (row[col] != args[i]) return false;
      i++;
    }
    return true;
  }

  List<Map<String, Object?>> _sort(
    List<Map<String, Object?>> list,
    String orderBy,
  ) {
    final sorted = List<Map<String, Object?>>.from(list);
    final parts = orderBy.split(',').map((s) => s.trim()).toList();
    sorted.sort((a, b) {
      for (final part in parts) {
        final desc = part.toLowerCase().endsWith(' desc');
        final col =
            desc ? part.substring(0, part.length - 5).trim() : part;
        final av = a[col];
        final bv = b[col];
        final cmp = _cmp(av, bv);
        if (cmp != 0) return desc ? -cmp : cmp;
      }
      return 0;
    });
    return sorted;
  }

  int _cmp(Object? a, Object? b) {
    if (a == b) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }
}
