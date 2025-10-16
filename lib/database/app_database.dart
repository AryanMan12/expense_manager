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
    print("Creating tables...");
    await db.execute(userTransactionsDB.createQuery);
    await db.execute(userDB.createQuery);
    print("Tables created successfully.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from $oldVersion to $newVersion");
    if (oldVersion < 4) {
      final userDB = UserDBService();
      await db.execute(userDB.createQuery);
    }
  }

  Future<Database> _initializedDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 4,
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
