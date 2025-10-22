import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseCategoryDBService {
  // SQL query to create the expense_group table
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $iconField $textType,
    $tagsField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType
  );
  """;

  // Insert a new expense group into the database
  Future<int> insert(ExpenseCategoryModel expenseCategoryModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, expenseCategoryModel.toJson());
    return savedId;
  }

  // Get all expense groups from the database
  Future<List<ExpenseCategoryModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<ExpenseCategoryModel> expenseGroups = [];
    expenseGroups = List<ExpenseCategoryModel>.from(
      allData.map((x) => ExpenseCategoryModel.fromJson(x)),
    );

    return expenseGroups;
  }

  // Get a specific expense group by ID
  Future<ExpenseCategoryModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ExpenseCategoryModel.fromJson(result.first);
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
  Future<int> update(ExpenseCategoryModel expenseCategoryModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      expenseCategoryModel.toJson(),
      where: "$idField = ?",
      whereArgs: [expenseCategoryModel.id],
    );
  }

  // In ExpenseCategoryDBService
  Future<ExpenseCategoryModel?> getByName(String name) async {
    final db = await AppDatabase.instance.database;
    final res = await db.query(tableName, where: 'name = ?', whereArgs: [name]);
    return res.isNotEmpty ? ExpenseCategoryModel.fromJson(res.first) : null;
  }

  // Delete all expense groups from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
