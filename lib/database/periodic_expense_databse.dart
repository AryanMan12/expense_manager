import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/periodic_expense_db_model.dart';
import 'package:sqflite/sqflite.dart';

class PeriodicExpenseDBService {
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $tagsField $textType,
    $amountField $notNulldecimalType,
    $descriptionField $textType,
    $onUserIdField $notNullIntType,
    $expenseGroupField $notNullIntType,
    $periodicDateField $textType,
    $repeatsEveryField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType,
    $isActiveField $notNullIntType
  );
  """;

  // Insert a new periodic expense into the database
  Future<int> insert(PeriodicExpenseModel periodicExpenseModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, periodicExpenseModel.toJson());
    return savedId;
  }

  // Get all periodic expenses from the database
  Future<List<PeriodicExpenseModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<PeriodicExpenseModel> periodicExpenses = [];
    periodicExpenses = List<PeriodicExpenseModel>.from(
      allData.map((x) => PeriodicExpenseModel.fromJson(x)),
    );

    return periodicExpenses;
  }

  // Get a specific periodic expense by ID
  Future<PeriodicExpenseModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PeriodicExpenseModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete a periodic expense by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing periodic expense in the database
  Future<int> update(PeriodicExpenseModel periodicExpenseModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      periodicExpenseModel.toJson(),
      where: "$idField = ?",
      whereArgs: [periodicExpenseModel.id],
    );
  }

  // Delete all periodic expenses from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
