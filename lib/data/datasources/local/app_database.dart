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
      version: 1,
      onCreate: _onCreate,
    );
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
        order_index INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY,
        category TEXT NOT NULL,
        product TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        notes TEXT NOT NULL,
        status TEXT NOT NULL,
        order_index INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY,
        day TEXT NOT NULL,
        meal TEXT NOT NULL,
        name TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        preparation TEXT NOT NULL,
        origin TEXT NOT NULL,
        order_index INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE prep_tasks (
        id INTEGER PRIMARY KEY,
        order_index INTEGER NOT NULL,
        task TEXT NOT NULL,
        quantity TEXT NOT NULL,
        purpose TEXT NOT NULL,
        storage TEXT NOT NULL,
        status TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE plan_notes (
        id INTEGER PRIMARY KEY,
        topic TEXT NOT NULL,
        respected TEXT NOT NULL,
        applied TEXT NOT NULL,
        source TEXT NOT NULL,
        order_index INTEGER NOT NULL
      );
    ''');

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
}
