import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Set the path to the database
    final dateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss');
    String path = join((await getDownloadsDirectory())!.path,
        '${dateFormat.format(DateTime.now())}.db');
    print((await getDownloadsDirectory())!.path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the database schema
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp text,
        accelerometerDataTimestamp text,
        userAccelerometerDataTimestamp text,
        accelerometerData_X REAL,
        accelerometerData_Y REAL,
        accelerometerData_Z REAL,
        useraccelerometerData_X REAL,
        useraccelerometerData_Y REAL,
        useraccelerometerData_Z REAL,
        location_latitude REAL,
        location_longitude REAL
      )
    ''');
  }

  // Insert a user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('test', user);
  }

  Future<void> insertListData(List<Map<String, dynamic>> dataList) async {
    // トランザクションとバッチ処理でまとめて挿入
    Database db = await database;
    await db.transaction((txn) async {
      Batch batch = txn.batch();

      for (var data in dataList) {
        batch.insert('test', data);
      }

      await batch.commit(noResult: true); // noResult: true でパフォーマンス向上
    });
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('test');
  }

  // Close the database
  Future close() async {
    Database db = await database;
    db.close();
  }

  Future<void> insertBatch(List<Map<String, Object>> dataList) async {
    final db = await database;
    final batch = db.batch();

    for (var data in dataList) {
      batch.insert('users', {
        'timestamp': data['timestamp'],
        'useraccelerometerData_X': data['useraccelerometerData_X'],
        'useraccelerometerData_Y': data['useraccelerometerData_Y'],
        'useraccelerometerData_Z': data['useraccelerometerData_Z'],
        'location_latitude': data['location_latitude'],
        'location_longitude': data['location_longitude'],
      });
    }
    await batch.commit(noResult: true);
  }
}
