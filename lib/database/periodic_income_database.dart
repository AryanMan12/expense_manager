import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/database_models/periodic_income_db_model.dart';
import 'package:sqflite/sqflite.dart';

class PeriodicIncomeDBService {
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $tagsField $textType,
    $amountField $notNulldecimalType,
    $descriptionField $textType,
    $fromUserIdField $notNullIntType,
    $periodicDateField $textType,
    $repeatsEveryField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType,
    $isActiveField $notNullIntType
  );
  """;

  // Insert a new periodic income into the database
  Future<int> insert(PeriodicIncomeModel periodicIncomeModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, periodicIncomeModel.toJson());
    return savedId;
  }

  // Get all periodic incomes from the database
  Future<List<PeriodicIncomeModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<PeriodicIncomeModel> periodicIncomes = [];
    periodicIncomes = List<PeriodicIncomeModel>.from(
      allData.map((x) => PeriodicIncomeModel.fromJson(x)),
    );

    return periodicIncomes;
  }

  // Get a specific periodic income by ID
  Future<PeriodicIncomeModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PeriodicIncomeModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete a periodic income by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing periodic income in the database
  Future<int> update(PeriodicIncomeModel periodicIncomeModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      periodicIncomeModel.toJson(),
      where: "$idField = ?",
      whereArgs: [periodicIncomeModel.id],
    );
  }

  // Delete all periodic incomes from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
