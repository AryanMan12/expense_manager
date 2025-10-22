import 'dart:developer';
import 'package:expense_manager/database/expense_category_database.dart';
import 'package:expense_manager/database/expense_sub_category_database.dart';
import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/database/users_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._init();

  static final instance = AppDatabase._init();

  static Database? _database;

  final String fileName = "expense_manager_db";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializedDB(fileName);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    final userTransactionsDB = UserTransactionsDBService();
    final userDB = UserDBService();
    final expenseCategoryDB = ExpenseCategoryDBService();
    final expenseSubCategoryDB = ExpenseSubCategoryDBService();
    log("Creating tables...");
    await db.execute(userTransactionsDB.createQuery);
    await db.execute(userDB.createQuery);
    await db.execute(expenseCategoryDB.createQuery);
    await db.execute(expenseSubCategoryDB.createQuery);
    log("Tables created successfully.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log("Upgrading database from $oldVersion to $newVersion");
    if (oldVersion < 6) {
      final userTransactionsDB = UserTransactionsDBService();
      final userDB = UserDBService();
      final expenseCategoryDB = ExpenseCategoryDBService();
      final expenseSubCategoryDB = ExpenseSubCategoryDBService();
      await db.execute(userTransactionsDB.createQuery);
      await db.execute(userDB.createQuery);
      await db.execute(expenseCategoryDB.createQuery);
      await db.execute(expenseSubCategoryDB.createQuery);
    }
    log("Upgraded database from $oldVersion to $newVersion");
  }

  Future<Database> _initializedDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }
}

// DB version and changes
// 1: User Transaction Table Created
// 4: Users Table Created
// 5: Added Category and Sub Category
// 6: Added Expense Sub Group column in User Transactions DB
