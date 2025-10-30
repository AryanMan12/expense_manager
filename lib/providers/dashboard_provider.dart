import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:provider/provider.dart';

class DashboardDataProvider extends ChangeNotifier {
  final UserTransactionsDBService _dbService = UserTransactionsDBService();
  late ExpenseCategoryProvider categoryProvider;

  bool isLoading = false;
  List<UserTransactionModel> transactions = [];

  Map<String, double> topCategories = {};
  Map<String, double> topSubCategories = {};
  Map<String, Map<String, double>> payerReceiverData = {};
  Map<DateTime, double> dailyTotals = {};
  double totalBorrowed = 0.0;
  double totalLent = 0.0;

  Future<void> loadDashboardData({
    required BuildContext context,
    required DateTime startDate,
    required DateTime endDate,
    String currentUserName = "Username",
  }) async {
    isLoading = true;
    categoryProvider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );
    topCategories.clear();
    topSubCategories.clear();
    payerReceiverData.clear();
    dailyTotals.clear();
    totalBorrowed = 0;
    totalLent = 0;
    notifyListeners();

    final txs = await _dbService.getTransactionsInRange(startDate, endDate);
    transactions = txs;

    await Future.wait([
      _computeCategoryTotals(txs),
      _computeSubCategoryTotals(txs),
      _computePayerReceiverData(txs, currentUserName: currentUserName),
      _computeDailyTrends(txs),
      _computeBorrowedLentTotals(startDate, endDate, currentUserName),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _computeBorrowedLentTotals(
    DateTime startDate,
    DateTime endDate,
    String userName,
  ) async {
    final result = await _dbService.getTotalBorrowedLentAmounts(
      startDate,
      endDate,
      userName,
    );

    totalBorrowed = result['totalBorrowed'] ?? 0.0;
    totalLent = result['totalLent'] ?? 0.0;
  }

  Map<String, double> getSubCategoryBreakdownForCategory(String categoryName) {
    final categoryId = categoryProvider.getCategoryIdByName(categoryName);
    if (categoryId == null) return {};

    final Map<String, double> subTotals = {};

    for (var tx in transactions) {
      if (tx.expenseGroupId != categoryId) continue;

      final subCat = categoryProvider
          .subCategoriesForCategory(categoryId)
          .firstWhere(
            (sub) => sub.id == tx.expenseSubGroupId,
            orElse: () => ExpenseSubCategoryModel(id: 0, name: "Unknown"),
          );

      subTotals[subCat.name ?? "Unknown"] =
          (subTotals[subCat.name ?? "Unknown"] ?? 0) + (tx.amount ?? 0);
    }

    return Map.fromEntries(
      subTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<UserTransactionModel> getTransactionsForSubCategory(
    String subCategoryName,
  ) {
    final subCategory = categoryProvider.getSubCategoryByName(subCategoryName);
    if (subCategory == null) return [];

    return transactions
        .where((tx) => tx.expenseSubGroupId == subCategory.id)
        .toList();
  }

  Future<void> _computeCategoryTotals(List<UserTransactionModel> txs) async {
    final Map<String, double> categoryTotals = {};
    for (var tx in txs) {
      final key = categoryProvider.getCategoryNameById(tx.expenseGroupId);
      categoryTotals[key] = (categoryTotals[key] ?? 0) + (tx.amount ?? 0);
    }

    topCategories = Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _computeSubCategoryTotals(List<UserTransactionModel> txs) async {
    final Map<String, double> subCategoryTotals = {};
    for (var tx in txs) {
      final key = categoryProvider
          .subCategoriesForCategory(tx.expenseGroupId!)
          .firstWhere(
            (sub) => sub.id == tx.expenseSubGroupId,
            orElse: () => ExpenseSubCategoryModel(id: 0, name: "Unknown"),
          )
          .name;
      subCategoryTotals[key!] =
          (subCategoryTotals[key] ?? 0) + (tx.amount ?? 0);
    }

    topSubCategories = Map.fromEntries(
      subCategoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _computePayerReceiverData(
    List<UserTransactionModel> txs, {
    String currentUserName = "Username",
  }) async {
    final Map<String, Map<String, double>> summary = {
      "Spent On": {},
      "Earned From": {},
      "Lent To": {},
      "Borrowed From": {},
      "Self": {},
    };

    for (var tx in txs) {
      final payer = tx.payerName ?? "Unknown";
      final receiver = tx.receiverName ?? "Unknown";
      final amount = tx.amount ?? 0;
      final isLent =
          tx.isBorrowedOrLended == 1 && tx.payerName == currentUserName;
      final isBorrowed =
          tx.isBorrowedOrLended == 1 && tx.payerName != currentUserName;

      if (payer == currentUserName && receiver == currentUserName) {
        summary["Self"]!["Myself"] = (summary["Self"]!["Myself"] ?? 0) + amount;
      } else if (payer == currentUserName && receiver != currentUserName) {
        if (isLent) {
          summary["Lent To"]![receiver] =
              (summary["Lent To"]![receiver] ?? 0) + amount;
        } else {
          summary["Spent On"]![receiver] =
              (summary["Spent On"]![receiver] ?? 0) + amount;
        }
      } else if (receiver == currentUserName && payer != currentUserName) {
        if (isBorrowed) {
          summary["Borrowed From"]![payer] =
              (summary["Borrowed From"]![payer] ?? 0) + amount;
        } else {
          summary["Earned From"]![payer] =
              (summary["Earned From"]![payer] ?? 0) + amount;
        }
      }
    }

    payerReceiverData = summary;
  }

  List<UserTransactionModel> getTransactionsForPerson(
    String personName,
    String relationType,
    String currentUserName,
  ) {
    return transactions.where((tx) {
      final payer = tx.payerName ?? "";
      final receiver = tx.receiverName ?? "";
      final isLent =
          tx.isBorrowedOrLended == 1 && tx.payerName == currentUserName;
      final isBorrowed =
          tx.isBorrowedOrLended == 1 && tx.payerName != currentUserName;

      switch (relationType) {
        case "Spent On":
          return payer == currentUserName && receiver == personName && !isLent;
        case "Earned From":
          return receiver == currentUserName &&
              payer == personName &&
              !isBorrowed;
        case "Lent To":
          return payer == currentUserName && receiver == personName && isLent;
        case "Borrowed From":
          return receiver == currentUserName &&
              payer == personName &&
              isBorrowed;
        case "Self":
          return payer == currentUserName && receiver == currentUserName;
        default:
          return false;
      }
    }).toList();
  }

  Map<String, double> getCategoryBreakdownForPerson(
    String personName,
    String relationType,
    String currentUserName,
  ) {
    final relatedTxs = getTransactionsForPerson(
      personName,
      relationType,
      currentUserName,
    );
    final Map<String, double> categoryTotals = {};

    for (var tx in relatedTxs) {
      final categoryName = categoryProvider.getCategoryNameById(
        tx.expenseGroupId,
      );
      if (categoryName.isEmpty) continue;
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + (tx.amount ?? 0);
    }

    final sorted = Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sorted;
  }

  Future<void> _computeDailyTrends(List<UserTransactionModel> txs) async {
    final Map<DateTime, double> trends = {};

    for (var tx in txs) {
      if (tx.expenseDate == null) continue;
      final date = DateTime.parse(tx.expenseDate!);
      final day = DateTime(date.year, date.month, date.day);
      trends[day] = (trends[day] ?? 0) + (tx.amount ?? 0);
    }

    dailyTotals = Map.fromEntries(
      trends.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}
