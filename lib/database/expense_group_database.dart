import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/database_models/expense_group_db_model.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseGroupDBService {
  // SQL query to create the expense_group table
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $tagsField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType
  );
  """;

  // Insert a new expense group into the database
  Future<int> insert(ExpenseGroupModel expenseGroupModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, expenseGroupModel.toJson());
    return savedId;
  }

  // Get all expense groups from the database
  Future<List<ExpenseGroupModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<ExpenseGroupModel> expenseGroups = [];
    expenseGroups = List<ExpenseGroupModel>.from(
      allData.map((x) => ExpenseGroupModel.fromJson(x)),
    );

    return expenseGroups;
  }

  // Get a specific expense group by ID
  Future<ExpenseGroupModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ExpenseGroupModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete an expense group by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing expense group in the database
  Future<int> update(ExpenseGroupModel expenseGroupModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      expenseGroupModel.toJson(),
      where: "$idField = ?",
      whereArgs: [expenseGroupModel.id],
    );
  }

  // Delete all expense groups from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
