import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseSubCategoryDBService {
  // SQL query to create the expense_group table
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $categoryIdField $notNullIntType,
    $nameField $notNullTextType,
    $iconField $textType,
    $tagsField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType
  );
  """;

  // Insert a new expense group into the database
  Future<int> insert(ExpenseSubCategoryModel expenseSubCategoryModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, expenseSubCategoryModel.toJson());
    return savedId;
  }

  // Get all expense groups from the database
  Future<List<ExpenseSubCategoryModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<ExpenseSubCategoryModel> expenseGroups = [];
    expenseGroups = List<ExpenseSubCategoryModel>.from(
      allData.map((x) => ExpenseSubCategoryModel.fromJson(x)),
    );

    return expenseGroups;
  }

  // Get a specific expense group by ID
  Future<ExpenseSubCategoryModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ExpenseSubCategoryModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<List<ExpenseSubCategoryModel>> getByCategoryId(int categoryId) async {
    final db = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      tableName, // should be your subcategory table name
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return result
        .map((json) => ExpenseSubCategoryModel.fromJson(json))
        .toList();
  }

  // Delete an expense group by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing expense group in the database
  Future<int> update(ExpenseSubCategoryModel expenseSubCategoryModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      expenseSubCategoryModel.toJson(),
      where: "$idField = ?",
      whereArgs: [expenseSubCategoryModel.id],
    );
  }

  // Delete all expense groups from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
