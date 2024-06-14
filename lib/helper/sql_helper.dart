import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('harvest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user VARCHAR(5) NOT NULL,
        name VARCHAR(100) NOT NULL,
        username VARCHAR(100) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE trees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tree VARCHAR(5) NOT NULL,
        lat VARCHAR(100) NOT NULL,
        long VARCHAR(100) NOT NULL,
        name VARCHAR(100) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user VARCHAR(5) NOT NULL,
        id_tree VARCHAR(5) NOT NULL,
        lat VARCHAR(30) NOT NULL,
        long VARCHAR(30) NOT NULL,
        name VARCHAR(100) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user VARCHAR(5) NOT NULL,
        lat VARCHAR(30) NOT NULL,
        long VARCHAR(30) NOT NULL,
        tipe VARCHAR(5) NOT NULL,
        date TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE harvest(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user VARCHAR(5) NOT NULL,
        name VARCHAR(100) NOT NULL,
        qty INTEGER NOT NULL,
        id_tree INTEGER NOT NULL,
        lat VARCHAR(30) NOT NULL,
        long VARCHAR(30) NOT NULL,
        tipe VARCHAR(2) NOT NULL,
        date TEXT
      )
    ''');
  }

  // CRUD Operations
  Future<int> insert(Map<String, dynamic> row, String table) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(
      String table, String filter, String id) async {
    Database db = await database;
    return await db.query(table, where: "$filter = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsDobule(String table,
      String filter1, String filter2, String where1, String where2) async {
    Database db = await database;
    String whereClause = "$filter1 = ? AND $filter2 = ?";
    List<String> whereArgs = [where1, where2];
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> queryRow(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  Future<int> update(
      Map<String, dynamic> row, String table, String filter, String id) async {
    Database db = await database;
    return await db.update(table, row, where: filter + ' = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, String table, String filter) async {
    Database db = await database;
    return await db
        .delete(table, where: filter + ' = ?', whereArgs: [id.toString()]);
  }

  Future<void> truncate(String table) async {
    Database db = await database;
    await db.delete(table);
  }
}
