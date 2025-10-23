import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:intl/intl.dart';

class DashboardDataProvider extends ChangeNotifier {
  final UserTransactionsDBService _dbService = UserTransactionsDBService();

  bool isLoading = false;
  List<UserTransactionModel> transactions = [];

  Map<String, double> topCategories = {};
  Map<String, double> topSubCategories = {};
  Map<String, double> payerBreakdown = {};
  Map<String, Map<String, double>> payerReceiverData = {};
  Map<DateTime, double> dailyTotals = {};

  Future<void> loadDashboardData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    isLoading = true;
    notifyListeners();

    final txs = await _dbService.getTransactionsInRange(startDate, endDate);
    transactions = txs;

    await _computeCategoryTotals(txs);
    await _computeSubCategoryTotals(txs);
    await _computePayerBreakdown(txs);
    await _computePayerReceiverData(txs);
    await _computeDailyTrends(txs);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _computeCategoryTotals(List<UserTransactionModel> txs) async {
    final Map<String, double> categoryTotals = {};
    for (var tx in txs) {
      final key = "Category ${tx.expenseGroupId ?? 0}";
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
      final key = "SubCategory ${tx.expenseGroupId ?? 0}";
      subCategoryTotals[key] = (subCategoryTotals[key] ?? 0) + (tx.amount ?? 0);
    }

    topSubCategories = Map.fromEntries(
      subCategoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _computePayerBreakdown(List<UserTransactionModel> txs) async {
    final Map<String, double> payerTotals = {};
    for (var tx in txs) {
      final payer = tx.payerName ?? "Unknown";
      payerTotals[payer] = (payerTotals[payer] ?? 0) + (tx.amount ?? 0);
    }

    payerBreakdown = Map.fromEntries(
      payerTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _computePayerReceiverData(List<UserTransactionModel> txs) async {
    final Map<String, Map<String, double>> matrix = {};

    for (var tx in txs) {
      final payer = tx.payerName ?? "Unknown";
      final receiver = tx.receiverName ?? "Unknown";
      final amount = tx.amount ?? 0;

      matrix.putIfAbsent(payer, () => {});
      matrix[payer]![receiver] = (matrix[payer]![receiver] ?? 0) + amount;
    }

    payerReceiverData = matrix;
  }

  Future<void> _computeDailyTrends(List<UserTransactionModel> txs) async {
    final Map<DateTime, double> trends = {};
    final formatter = DateFormat('yyyy-MM-dd');

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
