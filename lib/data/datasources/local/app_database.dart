import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'seed_data.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'dietario.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE day_meals ADD COLUMN remote_id TEXT');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS day_meals_remote_id_idx ON day_meals(remote_id) WHERE remote_id IS NOT NULL');
      await db.execute('ALTER TABLE shopping_items ADD COLUMN remote_id TEXT');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS shopping_items_remote_id_idx ON shopping_items(remote_id) WHERE remote_id IS NOT NULL');
      await db.execute('ALTER TABLE recipes ADD COLUMN remote_id TEXT');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS recipes_remote_id_idx ON recipes(remote_id) WHERE remote_id IS NOT NULL');
      await db.execute('ALTER TABLE prep_tasks ADD COLUMN remote_id TEXT');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS prep_tasks_remote_id_idx ON prep_tasks(remote_id) WHERE remote_id IS NOT NULL');
      await db.execute('ALTER TABLE plan_notes ADD COLUMN remote_id TEXT');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS plan_notes_remote_id_idx ON plan_notes(remote_id) WHERE remote_id IS NOT NULL');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE day_meals (
        id INTEGER PRIMARY KEY,
        day TEXT NOT NULL,
        slot TEXT NOT NULL,
        text TEXT NOT NULL,
        menu_code TEXT,
        note TEXT,
        order_index INTEGER NOT NULL,
        remote_id TEXT
      );
    ''');
    await db.execute(
        'CREATE UNIQUE INDEX day_meals_remote_id_idx ON day_meals(remote_id) WHERE remote_id IS NOT NULL');

    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY,
        category TEXT NOT NULL,
        product TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        notes TEXT NOT NULL,
        status TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        remote_id TEXT
      );
    ''');
    await db.execute(
        'CREATE UNIQUE INDEX shopping_items_remote_id_idx ON shopping_items(remote_id) WHERE remote_id IS NOT NULL');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY,
        day TEXT NOT NULL,
        meal TEXT NOT NULL,
        name TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        preparation TEXT NOT NULL,
        origin TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        remote_id TEXT
      );
    ''');
    await db.execute(
        'CREATE UNIQUE INDEX recipes_remote_id_idx ON recipes(remote_id) WHERE remote_id IS NOT NULL');

    await db.execute('''
      CREATE TABLE prep_tasks (
        id INTEGER PRIMARY KEY,
        order_index INTEGER NOT NULL,
        task TEXT NOT NULL,
        quantity TEXT NOT NULL,
        purpose TEXT NOT NULL,
        storage TEXT NOT NULL,
        status TEXT NOT NULL,
        remote_id TEXT
      );
    ''');
    await db.execute(
        'CREATE UNIQUE INDEX prep_tasks_remote_id_idx ON prep_tasks(remote_id) WHERE remote_id IS NOT NULL');

    await db.execute('''
      CREATE TABLE plan_notes (
        id INTEGER PRIMARY KEY,
        topic TEXT NOT NULL,
        respected TEXT NOT NULL,
        applied TEXT NOT NULL,
        source TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        remote_id TEXT
      );
    ''');
    await db.execute(
        'CREATE UNIQUE INDEX plan_notes_remote_id_idx ON plan_notes(remote_id) WHERE remote_id IS NOT NULL');

    await db.execute('''
      CREATE TABLE meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    final batch = db.batch();
    for (final r in MenuSeed.build()) {
      batch.insert('day_meals', r);
    }
    for (final r in ShoppingSeed.build()) {
      batch.insert('shopping_items', r);
    }
    for (final r in RecipeSeed.build()) {
      batch.insert('recipes', r);
    }
    for (final r in PrepSeed.build()) {
      batch.insert('prep_tasks', r);
    }
    for (final r in PlanNoteSeed.build()) {
      batch.insert('plan_notes', r);
    }
    for (final r in MetaSeed.build()) {
      batch.insert('meta', r);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Replace all rows of a table with [rows] in a single transaction.
  /// Used to apply a full pull from remote into local.
  Future<void> replaceAll(
    String table,
    List<Map<String, Object?>> rows,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(table);
      final batch = txn.batch();
      for (final row in rows) {
        batch.rawInsert(
          'INSERT OR REPLACE INTO $table (${row.keys.join(',')}) '
          'VALUES (${List.filled(row.length, '?').join(',')})',
          row.values.toList(),
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Insert a row, replacing any existing row that has the same `remote_id`.
  /// Returns the local row id.
  Future<int> upsertByRemoteId(
    String table,
    Map<String, Object?> row,
  ) async {
    final remoteId = row['remote_id'];
    final db = await database;
    if (remoteId == null) {
      return db.insert(table, row);
    }
    final existing = await db.query(
      table,
      columns: ['id'],
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );
    if (existing.isEmpty) {
      return db.insert(table, row);
    }
    final id = existing.first['id'] as int;
    await db.update(
      table,
      row..['id'] = id,
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }

  Future<void> deleteByRemoteId(String table, String remoteId) async {
    final db = await database;
    await db.delete(
      table,
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }

  Future<void> setRemoteId(String table, int id, String remoteId) async {
    final db = await database;
    await db.update(
      table,
      {'remote_id': remoteId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
