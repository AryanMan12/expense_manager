import 'package:expense_manager/database/user_transactions_database.dart';
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
    await db.execute(userTransactionsDB.createQuery);
  }

  Future<Database> _initializedDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }
}
