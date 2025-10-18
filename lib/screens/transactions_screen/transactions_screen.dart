import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/main_screen/widgets/initial_name_popup.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/overview_widget.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/single_transaction_list_tile.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/expense_entry_popup.dart';
import 'package:flutter/material.dart';
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

  List<UserTransactionModel> filteredTransactions = [];

  double totalAmount = 0.0;
  int totalTransactions = 0;
  int borrowLendTransactions = 0;

  int? selectedIndex;

  late UserDetailsProvider _userDetailsProvider;

  @override
  initState() {
    super.initState();
    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );
    _loadUserDetails();
    _loadTransactions();
  }

  Future<void> _loadUserDetails() async {
    if (_userDetailsProvider.user?.name == null) {
      await showNameInputDialog(context);
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);

    // Get start and end dates based on the selected period
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedPeriod) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(Duration(days: 1));
        break;
      case 'Week':
        startDate = now.subtract(
          Duration(days: now.weekday - 1),
        ); // Start of week (Monday)
        endDate = startDate.add(Duration(days: 7)); // End of the week (Sunday)
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
        throw Exception("Invalid time period");
    }

    final dbService = UserTransactionsDBService();
    List<UserTransactionModel> transactions = await dbService
        .getTransactionsInRange(startDate, endDate);

    // Process data
    totalAmount = transactions.fold(0.0, (sum, transaction) {
      return sum + (transaction.amount ?? 0);
    });

    totalTransactions = transactions.length;

    borrowLendTransactions = transactions
        .where((transaction) => transaction.isBorrowedOrLended != 2)
        .length;

    setState(() {
      filteredTransactions = transactions;
      selectedIndex = null;
      isLoading = false;
    });
  }

  Future<void> openAddExpensePopup() async {
    setState(() => isExpensePopupOpen = !isExpensePopupOpen);
  }

  Widget _buildPeriodButton(String period) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: () {
          setState(() => selectedPeriod = period);
          _loadTransactions();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPeriod == period
              ? Colors.deepPurpleAccent
              : Colors.grey,
        ),
        child: Text(period, style: TextStyle(color: Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appDataProvider, child) {
        return Scaffold(
          body: _userDetailsProvider.user?.name == null
              ? Center(child: Text("Waiting For Useranme"))
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              // Overview Card
                              OverviewCard(
                                totalAmount: totalAmount,
                                totalTransactions: totalTransactions,
                                borrowLendTransactions: borrowLendTransactions,
                              ),
                              const SizedBox(height: 20),
                              // Time Period Selector
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPeriodButton("Day"),
                                  _buildPeriodButton("Week"),
                                  _buildPeriodButton("Month"),
                                  _buildPeriodButton("Year"),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Loading Spinner
                              if (isLoading)
                                Center(child: CircularProgressIndicator())
                              else
                                // List of Transactions
                                filteredTransactions.isEmpty
                                    ? Center(child: Text("No Transactions Yet"))
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
