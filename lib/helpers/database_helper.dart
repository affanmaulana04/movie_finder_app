import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';


class DatabaseHelper {
  static const _databaseName = "MovieFinder.db";
  static const _databaseVersion = 2; // Naikkan versi karena ada perubahan skema

  static const tableFavorites = 'favorites';
  static const tableUsers = 'users';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableFavorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            title TEXT NOT NULL,
            posterUrl TEXT NOT NULL,
            synopsis TEXT NOT NULL,
            genre TEXT,
            actors TEXT,
            UNIQUE(userId, title)
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableUsers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
          ''');
  }

  // Handle upgrade database jika skema berubah
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $tableFavorites ADD COLUMN genre TEXT");
      await db.execute("ALTER TABLE $tableFavorites ADD COLUMN actors TEXT");
    }
  }

  Future<int> addFavorite(Map<String, dynamic> movie) async {
    Database db = await instance.database;
    return await db.insert(tableFavorites, movie, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    Database db = await instance.database;
    return await db.query(tableFavorites, where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> removeFavorite(int userId, String title) async {
    Database db = await instance.database;
    return await db.delete(tableFavorites, where: 'userId = ? AND title = ?', whereArgs: [userId, title]);
  }

  Future<int> addUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    Database db = await instance.database;
    final res = await db.query(
      tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }
}