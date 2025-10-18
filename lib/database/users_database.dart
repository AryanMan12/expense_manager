import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/users_db_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDBService {
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $totalField $notNulldecimalType,
    $savingsField $notNulldecimalType,
    $investedField $notNulldecimalType,
    $dailyLimitField $notNulldecimalType,
    $moneyLeftFromDailyField $notNulldecimalType,
    $moneyBorrowedField $notNulldecimalType,
    $moneyLendField $notNulldecimalType,
    $createdDateField $textType,
    $modifiedDateField $textType,
    $isActiveField $notNullIntType
  );
  """;

  // Insert a new user into the database
  Future<int> insert(UserModel userModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, userModel.toJson());
    return savedId;
  }

  // Get all users from the database
  Future<List<UserModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<UserModel> users = [];
    users = List<UserModel>.from(allData.map((x) => UserModel.fromJson(x)));

    return users;
  }

  // Get a specific user by ID
  Future<UserModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return UserModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete a user by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing user in the database
  Future<int> update(UserModel userModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      userModel.toJson(),
      where: "$idField = ?",
      whereArgs: [userModel.id],
    );
  }

  // Delete all users from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
