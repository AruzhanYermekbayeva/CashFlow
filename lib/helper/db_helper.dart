import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/transactions_model.dart';
import '../models/goals_model.dart';

class DatabaseHelper {
  static const _databaseName = "finance.db";
  static const _databaseVersion = 1;

  static const transactionsTable = 'transactions';
  static const goalsTable = 'goals';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal(); // Private constructor

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        // Web implementation (note: sqflite doesn't work on web)
        throw UnsupportedError('Web not supported - use shared_preferences instead');
      } else {
        // Mobile/Desktop implementation
        final directory = await getApplicationDocumentsDirectory();
        final path = join(directory.path, _databaseName);
        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
        );
      }
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        lat REAL,
        lng REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE $goalsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ========== TRANSACTION METHODS ==========
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(transactionsTable, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(transactionsTable);
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== GOAL METHODS ==========
  Future<int> insertGoal(GoalModel goal) async {
    final db = await database;
    return await db.insert(goalsTable, goal.toMap());
  }

  Future<List<GoalModel>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(goalsTable);
    return List.generate(maps.length, (i) => GoalModel.fromMap(maps[i]));
  }

  Future<int> updateGoal(GoalModel goal) async {
    final db = await database;
    return await db.update(
      goalsTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      goalsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}