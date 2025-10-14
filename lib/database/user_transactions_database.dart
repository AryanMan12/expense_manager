import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/database_models/user_transactions_db_model.dart';
import 'package:sqflite/sqflite.dart';

class UserTransactionsDBService {
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $payerNameField $notNullTextType,
    $receiverNameField $notNullTextType,
    $amountField $notNulldecimalType,
    $descriptionField $notNullTextType,
    $expenseGroupIdField $notNullIntType,
    $eventIdField $notNullIntType,
    $splitTransactionIdField $intType,
    $isBorrowedOrLendedField $notNullIntType,
    $expenseDateField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType
  );
  """;

  // Insert a new user transaction into the database
  Future<int> insert(UserTransactionModel userTransactionModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, userTransactionModel.toJson());
    return savedId;
  }

  // Get all user transactions from the database
  Future<List<UserTransactionModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<UserTransactionModel> userTransactions = [];
    userTransactions = List<UserTransactionModel>.from(
      allData.map((x) => UserTransactionModel.fromJson(x)),
    );

    return userTransactions;
  }

  // Get a specific user transaction by ID
  Future<UserTransactionModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return UserTransactionModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete a user transaction by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing user transaction in the database
  Future<int> update(UserTransactionModel userTransactionModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      userTransactionModel.toJson(),
      where: "$idField = ?",
      whereArgs: [userTransactionModel.id],
    );
  }

  // Delete all user transactions from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }

  Future<double> getTotalAmountSpent(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await AppDatabase.instance.database;

    // Convert DateTime to String for comparison
    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT SUM($amountField) as totalSpent
       FROM $tableName
       WHERE $expenseDateField BETWEEN ? AND ?''',
      [startDateString, endDateString],
    );

    if (result.isNotEmpty && result.first['totalSpent'] != null) {
      return result.first['totalSpent'] as double;
    } else {
      return 0.0;
    }
  }

  Future<Map<String, double>> getTotalBorrowedLentAmounts(
    DateTime startDate,
    DateTime endDate,
    String userName,
  ) async {
    Database db = await AppDatabase.instance.database;

    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final List<Map<String, dynamic>> borrowedResult = await db.rawQuery(
      '''SELECT SUM($amountField) as totalBorrowed
       FROM $tableName
       WHERE ($expenseDateField BETWEEN ? AND ?) AND $isBorrowedOrLendedField = 1 AND $payerNameField != ?''',
      [startDateString, endDateString, userName],
    );

    final List<Map<String, dynamic>> lentResult = await db.rawQuery(
      '''SELECT SUM($amountField) as totalLent
       FROM $tableName
       WHERE( $expenseDateField BETWEEN ? AND ?) AND $isBorrowedOrLendedField = 1 AND $payerNameField = ?''',
      [startDateString, endDateString, userName],
    );

    return {
      'totalBorrowed':
          borrowedResult.isNotEmpty &&
              borrowedResult.first['totalBorrowed'] != null
          ? borrowedResult.first['totalBorrowed'] as double
          : 0.0,
      'totalLent':
          lentResult.isNotEmpty && lentResult.first['totalLent'] != null
          ? lentResult.first['totalLent'] as double
          : 0.0,
    };
  }

  Future<Map<String, double>> getExpensesByPayer(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await AppDatabase.instance.database;

    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT $payerNameField, SUM($amountField) as totalSpent
       FROM $tableName
       WHERE ($expenseDateField BETWEEN ? AND ?)
       GROUP BY $payerNameField''',
      [startDateString, endDateString],
    );

    Map<String, double> payerExpenses = {};
    for (var row in result) {
      payerExpenses[row[payerNameField]] = row['totalSpent'] as double;
    }

    return payerExpenses;
  }

  Future<Map<int, double>> getExpensesByGroup(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await AppDatabase.instance.database;

    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT $expenseGroupIdField, SUM($amountField) as totalSpent
       FROM $tableName
       WHERE ($expenseDateField BETWEEN ? AND ?)
       GROUP BY $expenseGroupIdField''',
      [startDateString, endDateString],
    );

    Map<int, double> groupExpenses = {};
    for (var row in result) {
      groupExpenses[row[expenseGroupIdField]] = row['totalSpent'] as double;
    }

    return groupExpenses;
  }

  Future<List<UserTransactionModel>> getTransactionsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await AppDatabase.instance.database;

    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final List<Map<String, dynamic>> allData = await db.query(
      tableName,
      where: "$expenseDateField BETWEEN ? AND ?",
      whereArgs: [startDateString, endDateString],
    );

    List<UserTransactionModel> userTransactions = allData
        .map((x) => UserTransactionModel.fromJson(x))
        .toList();

    return userTransactions;
  }
}
