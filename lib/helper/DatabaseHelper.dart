import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE device_info(id INTEGER PRIMARY KEY, device_id TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertDeviceId(String deviceId) async {
    final db = await database;
    await db.insert(
      'device_info',
      {'device_id': deviceId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getDeviceId() async {
    final db = await database;
    final List<Map<String, dynamic>> results =
    await db.query('device_info', limit: 1);

    if (results.isNotEmpty) {
      return results.first['device_id'] as String;
    }
    return null; // Return null if no data is found
  }
}
