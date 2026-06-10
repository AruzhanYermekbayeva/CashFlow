import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:hive_flutter/hive_flutter.dart';
abstract class BaseDatabaseHelper {
  Future<void> init();
  Future<List<Map<String, dynamic>>> getTransactions();
  Future<int> insertTransaction(Map<String, dynamic> transaction);
  Future<int> updateTransaction(Map<String, dynamic> transaction);
  Future<int> deleteTransaction(int id);
}

class MobileDatabaseHelper implements BaseDatabaseHelper {
  static const _databaseName = "finance.db";
  static const _databaseVersion = 1;
  static const table = 'transactions';

  static sql.Database? _database;

  @override
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);
    _database = await sql.openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        lat REAL,
        lng REAL
      )
    ''');
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    return await _database!.query(table);
  }

  @override
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    return await _database!.insert(table, transaction);
  }

  @override
  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    return await _database!.update(
      table,
      transaction,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    return await _database!.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class WebDatabaseHelper implements BaseDatabaseHelper {
  late Box _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('transactions');
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    return _box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    await _box.add(transaction);
    return _box.length - 1;
  }

  @override
  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    await _box.put(transaction['id'], transaction);
    return transaction['id'];
  }

  @override
  Future<int> deleteTransaction(int id) async {
    await _box.delete(id);
    return id;
  }
}

class DatabaseService {
  static late final BaseDatabaseHelper _helper;

  static Future<void> init() async {
    _helper = kIsWeb ? WebDatabaseHelper() : MobileDatabaseHelper();
    await _helper.init();
  }

  static Future<List<Map<String, dynamic>>> getTransactions() =>
      _helper.getTransactions();

  static Future<int> insertTransaction(Map<String, dynamic> transaction) =>
      _helper.insertTransaction(transaction);

  static Future<int> updateTransaction(Map<String, dynamic> transaction) =>
      _helper.updateTransaction(transaction);

  static Future<int> deleteTransaction(int id) =>
      _helper.deleteTransaction(id);
}