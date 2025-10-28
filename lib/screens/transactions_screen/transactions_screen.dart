import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/fixed_overview_card.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/scroll_overview_card.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/single_transaction_list_tile.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/expense_entry_popup.dart';
import 'package:expense_manager/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool isLoading = false;
  bool isExpensePopupOpen = false;
  String selectedPeriod = 'Month';

  DateTimeRange? customDateRange;
  DateTime? startDate;
  DateTime? endDate;

  List<UserTransactionModel> filteredTransactions = [];

  double totalAmount = 0.0;
  double totalBorrowed = 0.0;
  double totalLent = 0.0;
  double totalSavings = 0.0;
  double totalIncome = 0.0;
  double totalInvested = 0.0;
  int totalTransactions = 0;
  int borrowLendTransactions = 0;

  int? selectedIndex;

  late UserDetailsProvider _userDetailsProvider;
  late ExpenseCategoryProvider _expenseCategoryProvider;

  @override
  initState() {
    super.initState();
    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );
    _expenseCategoryProvider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );
    if (_expenseCategoryProvider.categories.isEmpty) {
      loadCategory();
    }
    _loadTransactions();
  }

  Future<void> loadCategory() async {
    _expenseCategoryProvider.fetchCategories();
    _expenseCategoryProvider.fetchSubCategories(1);
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();

    switch (selectedPeriod) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate!.add(Duration(days: 1));
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate!.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;
      case 'Custom':
        if (customDateRange == null) return;
        startDate = customDateRange!.start;
        endDate = customDateRange!.end.add(Duration(days: 1));
        break;
      default:
        return;
    }

    final dbService = UserTransactionsDBService();
    List<UserTransactionModel> transactions = await dbService
        .getTransactionsInRange(startDate!, endDate!);

    Map<String, double> borrowLendMap = await dbService
        .getTotalBorrowedLentAmounts(
          startDate!,
          endDate!,
          _userDetailsProvider.user?.name ?? "Username",
        );
    List<UserTransactionModel> savingsList = await dbService
        .getSavingsTransactions(startDate!, endDate!);
    List<UserTransactionModel> investmentList = await dbService
        .getInvestedTransactions(startDate!, endDate!);

    final actualExpenses = transactions.where(
      (t) =>
          t.payerName == _userDetailsProvider.user!.name! &&
          t.isBorrowedOrLended == 2,
    );

    final actualIncome = transactions.where(
      (t) =>
          t.payerName != _userDetailsProvider.user!.name! &&
          t.isBorrowedOrLended == 2,
    );

    setState(() {
      startDate = startDate;
      endDate = endDate;
      totalAmount = actualExpenses.fold(0.0, (sum, t) => sum + (t.amount ?? 0));
      totalIncome = actualIncome.fold(0.0, (sum, t) => sum + (t.amount ?? 0));
      totalTransactions = transactions.length;
      borrowLendTransactions = transactions
          .where((t) => t.isBorrowedOrLended != 2)
          .length;

      totalBorrowed = borrowLendMap['totalBorrowed'] ?? 0.0;
      totalLent = borrowLendMap['totalLent'] ?? 0.0;
      totalSavings = savingsList.fold(0.0, (sum, t) => sum + (t.amount ?? 0));
      totalInvested = investmentList.fold(
        0.0,
        (sum, t) => sum + (t.amount ?? 0),
      );

      totalAmount += totalLent;
      totalIncome += totalBorrowed;

      filteredTransactions = transactions;
      selectedIndex = null;
      isLoading = false;
    });
  }

  Future<void> openAddExpensePopup() async {
    setState(() => isExpensePopupOpen = !isExpensePopupOpen);
  }

  Widget _buildPeriodSelector() {
    final periods = ["Day", "Week", "Month", "Year", "Custom"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: periods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = selectedPeriod == period;

          return GestureDetector(
            onTap: () async {
              if (period == "Custom") {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: customDateRange,
                );

                if (picked != null) {
                  setState(() {
                    selectedPeriod = "Custom";
                    customDateRange = picked;
                  });
                  _loadTransactions();
                }
              } else {
                setState(() => selectedPeriod = period);
                _loadTransactions();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepPurple.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.deepPurple : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInsightModal(String type) async {
    List<UserTransactionModel> items = [];

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedPeriod) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(Duration(days: 1));
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;
      default:
        return;
    }

    final db = UserTransactionsDBService();

    if (type == "borrowed" || type == "lent") {
      final all = await db.getTransactionsInRange(startDate, endDate);
      items = all
          .where(
            (t) =>
                t.isBorrowedOrLended == 1 &&
                ((type == "borrowed" &&
                        t.payerName != _userDetailsProvider.user!.name) ||
                    (type == "lent" &&
                        t.payerName == _userDetailsProvider.user!.name)),
          )
          .toList();
    } else if (type == "savings") {
      items = await db.getSavingsTransactions(startDate, endDate);
    } else if (type == "investments") {
      items = await db.getInvestedTransactions(startDate, endDate);
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          if (items.isEmpty) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                "No ${toTitleCase(type)} data available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${toTitleCase(type)} Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        // Adjust below according to your model fields:
                        final displayName = item.payerName ?? "Unknown";
                        final amount = item.amount ?? 0.0;
                        final date = item.expenseDate != null
                            ? DateTime.parse(item.expenseDate!)
                            : DateTime.now();

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Icon(
                              _iconForType(type),
                              color: _colorForType(type),
                            ),
                            title: Text(toTitleCase(displayName)),
                            subtitle: Text(
                              "₹${amount.toStringAsFixed(2)} • ${_formatDate(date)}",
                            ),
                            trailing: (type == "borrowed" || type == "lent")
                                ? Text(
                                    type == "borrowed" ? "Borrowed" : "Lent",
                                    style: TextStyle(
                                      color: type == "borrowed"
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'borrowed':
        return Icons.call_received;
      case 'lent':
        return Icons.call_made;
      case 'savings':
        return Icons.savings;
      case 'invested':
        return Icons.show_chart;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'borrowed':
        return Colors.red;
      case 'lent':
        return Colors.green;
      case 'savings':
        return Colors.blue;
      case 'invested':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appDataProvider, child) {
        return Scaffold(
          body: Consumer<UserDetailsProvider>(
            builder: (context, userDetailsProvider, child) {
              return userDetailsProvider.user?.name == null
                  ? Center(child: Text("Waiting For Useranme"))
                  : Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _loadTransactions,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Overview
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Overview",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.deepPurple[400],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Divider(
                                            thickness: 1,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Fixed 3-card row
                                  OverviewFixedTopCards(
                                    balance:
                                        _userDetailsProvider.user?.total ?? 0.0,
                                    totalIncome: totalIncome,
                                    totalSpent: totalAmount,
                                    totalTransactions: totalTransactions,
                                  ),
                                  const SizedBox(height: 10),

                                  // Scrollable extra cards
                                  OverviewScrollTile(
                                    balance:
                                        _userDetailsProvider.user?.total ?? 0.0,
                                    totalSpent: totalAmount,
                                    totalTransactions: totalTransactions,
                                    totalBorrowed: totalBorrowed,
                                    totalLent: totalLent,
                                    totalSavings: totalSavings,
                                    totalInvested: totalInvested,
                                    onTap: _showInsightModal,
                                  ),

                                  const SizedBox(height: 15),
                                  Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 10),
                                  // Time Period Selector
                                  _buildPeriodSelector(),
                                  if (startDate != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        "From: ${DateFormat.yMMMd().format(startDate!)}  "
                                        "To: ${DateFormat.yMMMd().format(endDate!)}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 10),
                                  // Loading Spinner
                                  if (isLoading)
                                    Center(child: CircularProgressIndicator())
                                  else
                                    // List of Transactions
                                    filteredTransactions.isEmpty
                                        ? Expanded(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "No transactions found for the $selectedPeriod",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "Start by adding some expenses or income.",
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                              itemCount:
                                                  filteredTransactions.length,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return TransactionListTile(
                                                  transaction:
                                                      filteredTransactions[index],
                                                  userName: _userDetailsProvider
                                                      .user!
                                                      .name!,
                                                  onRefresh: _loadTransactions,
                                                  onEditClicked: () {
                                                    selectedIndex = index;
                                                    openAddExpensePopup();
                                                  },
                                                  groupName:
                                                      _expenseCategoryProvider
                                                          .getCategoryNameById(
                                                            filteredTransactions[index]
                                                                .expenseGroupId,
                                                          ) ??
                                                      "NA",
                                                );
                                              },
                                            ),
                                          ),
                                ],
                              ),
                              Visibility(
                                visible: isExpensePopupOpen,
                                child: ExpenseEntryPopup(
                                  userName: _userDetailsProvider.user!.name!,
                                  callBack: (val) {
                                    if (!val) return;
                                    _loadTransactions();
                                    setState(() => isExpensePopupOpen = false);
                                  },
                                  transactionToEdit: selectedIndex == null
                                      ? null
                                      : filteredTransactions[selectedIndex!],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: openAddExpensePopup,
            tooltip: 'Add Expense',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
