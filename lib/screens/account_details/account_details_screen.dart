import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/account_details/widgets/borrowed_lent_section.dart';
import 'package:expense_manager/screens/account_details/widgets/category_section.dart';
import 'package:expense_manager/widgets/custom_buttons/cusstom_button.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_box.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/screens/transactions_screen/widgets/expense_entry_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late TextEditingController usernameController;
  late TextEditingController currentBalanceController;
  late TextEditingController savingsController;
  late TextEditingController investmentController;
  late TextEditingController borrowedController;
  late TextEditingController lendedController;

  late UserDetailsProvider _userDetailsProvider;

  List<UserTransactionModel> savingsList = [];
  List<UserTransactionModel> investmentList = [];
  List<UserTransactionModel> borrowedList = [];
  List<UserTransactionModel> lendedList = [];

  UserTransactionModel? txn;

  final _txnService = UserTransactionsDBService();
  bool _isLoadingTransactions = false;
  bool isExpensePopupOpen = false;

  String lastEditedOn = "";

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    currentBalanceController = TextEditingController();
    savingsController = TextEditingController();
    investmentController = TextEditingController();
    borrowedController = TextEditingController();
    lendedController = TextEditingController();

    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );

    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = _userDetailsProvider.user;
    if (user != null) {
      setState(() {
        usernameController.text = user.name ?? '';
        currentBalanceController.text = user.total?.toStringAsFixed(2) ?? '';
        savingsController.text = user.savings?.toStringAsFixed(2) ?? '';
        investmentController.text = user.invested?.toStringAsFixed(2) ?? '';
        borrowedController.text = user.moneyBorrowed?.toStringAsFixed(2) ?? '';
        lendedController.text = user.moneyLend?.toStringAsFixed(2) ?? '';
        lastEditedOn = user.modifiedDate ?? DateTime.now().toString();
      });
    } else {
      setState(() {
        lastEditedOn = DateTime.now().toString();
      });
    }
    await _loadTransactionLists();
  }

  Future<void> _loadTransactionLists() async {
    setState(() => _isLoadingTransactions = true);
    final now = DateTime.now();
    final start = DateTime(now.year - 1); // last year (you can adjust)
    final username = _userDetailsProvider.user?.name ?? "";

    savingsList = await _txnService.getSavingsTransactions(start, now);
    investmentList = await _txnService.getInvestedTransactions(start, now);

    final all = await _txnService.getAll();
    borrowedList = all
        .where((t) => t.isBorrowedOrLended == 1 && t.payerName != username)
        .toList();
    lendedList = all
        .where((t) => t.isBorrowedOrLended == 1 && t.payerName == username)
        .toList();

    setState(() => _isLoadingTransactions = false);
  }

  Future<void> _openExpensePopup(String type) async {
    setState(() => isExpensePopupOpen = true);
  }

  Future<void> _editTransaction(UserTransactionModel txn) async {
    setState(() {
      isExpensePopupOpen = true;
      txn = txn;
    });
  }

  Future<void> _deleteTransaction(UserTransactionModel txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Entry"),
        content: const Text(
          "Are you sure you want to delete this transaction?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = UserTransactionsDBService();
      await db.delete(txn.id!);
      await _loadTransactionLists();
    }
  }

  bool validate() {
    // Check if username is not empty
    if (usernameController.text.trim().isEmpty) {
      _showErrorMessage("Please enter a valid username.");
      return false;
    }

    // Check if all other fields are numeric and non-empty
    if (_isEmptyOrInvalid(currentBalanceController.text)) {
      _showErrorMessage("Please enter a valid current balance.");
      return false;
    }

    if (_isEmptyOrInvalid(savingsController.text)) {
      _showErrorMessage("Please enter a valid savings amount.");
      return false;
    }

    if (_isEmptyOrInvalid(investmentController.text)) {
      _showErrorMessage("Please enter a valid investment amount.");
      return false;
    }

    if (_isEmptyOrInvalid(borrowedController.text)) {
      _showErrorMessage("Please enter a valid borrowed amount.");
      return false;
    }

    if (_isEmptyOrInvalid(lendedController.text)) {
      _showErrorMessage("Please enter a valid lended amount.");
      return false;
    }

    return true;
  }

  bool _isEmptyOrInvalid(String text) {
    return text.trim().isEmpty || double.tryParse(text.trim()) == null;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> saveUserDetails() async {
    if (!validate()) return;

    final now = DateTime.now().toString();
    final user = UserModel(
      id: 1,
      name: usernameController.text.trim(),
      total: double.tryParse(currentBalanceController.text.trim()) ?? 0.0,
      savings: double.tryParse(savingsController.text.trim()) ?? 0.0,
      invested: double.tryParse(investmentController.text.trim()) ?? 0.0,
      moneyBorrowed: double.tryParse(borrowedController.text.trim()) ?? 0.0,
      moneyLend: double.tryParse(lendedController.text.trim()) ?? 0.0,
      dailyLimit: 0.0,
      moneyLeftFromDaily: 0.0,
      createdDate: _userDetailsProvider.user!.createdDate ?? now,
      modifiedDate: now,
      isActive: true,
    );

    _userDetailsProvider.updateUserDetails(user);

    setState(() => lastEditedOn = now);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account details saved successfully")),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    currentBalanceController.dispose();
    savingsController.dispose();
    investmentController.dispose();
    borrowedController.dispose();
    lendedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserDetails();
          _loadTransactionLists();
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomScreenHeader(
                  screenName: "Account Details",
                  hasBack: true,
                  onBackClick: (callback) {
                    if (!callback) return;
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView(
                      children: [
                        CustomTextBox(
                          hintText: "Username",
                          controller: usernameController,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 10),
                        CustomTextBox(
                          hintText: "Current Balance",
                          controller: currentBalanceController,
                          icon: Icons.currency_rupee,
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextBox(
                          hintText: "Savings",
                          controller: savingsController,
                          icon: Icons.savings_rounded,
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextBox(
                          hintText: "Investment",
                          controller: investmentController,
                          icon: Icons.waterfall_chart_rounded,
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextBox(
                                hintText: "Borrowed",
                                controller: borrowedController,
                                icon: Icons.currency_rupee,
                                inputType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                iconColor: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextBox(
                                hintText: "Lended",
                                controller: lendedController,
                                icon: Icons.currency_rupee,
                                inputType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                iconColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Transaction Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        _isLoadingTransactions
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Column(
                                children: [
                                  CategoryTransactionsSection(
                                    title: "Savings",
                                    icon: Icons.savings,
                                    total:
                                        double.tryParse(
                                          savingsController.text,
                                        ) ??
                                        0,
                                    transactions: savingsList,
                                    onAddPressed: () =>
                                        _openExpensePopup("savings"),
                                    accent: Colors.teal,
                                    onEdit: (txn) => _editTransaction(txn),
                                    onDelete: (txn) => _deleteTransaction(txn),
                                  ),
                                  CategoryTransactionsSection(
                                    title: "Investments",
                                    icon: Icons.trending_up,
                                    total:
                                        double.tryParse(
                                          investmentController.text,
                                        ) ??
                                        0,
                                    transactions: investmentList,
                                    onAddPressed: () =>
                                        _openExpensePopup("investment"),
                                    accent: Colors.orange,
                                    onEdit: (txn) => _editTransaction(txn),
                                    onDelete: (txn) => _deleteTransaction(txn),
                                  ),
                                  BorrowedLentSection(
                                    title: "Borrowed",
                                    icon: Icons.trending_down,
                                    total:
                                        double.tryParse(
                                          borrowedController.text,
                                        ) ??
                                        0,
                                    transactions: borrowedList,
                                    onAddPressed: () =>
                                        _openExpensePopup("borrowed"),
                                    onEdit: (txn) => _editTransaction(txn),
                                    onDelete: (txn) => _deleteTransaction(txn),
                                    accent: Colors.redAccent,
                                  ),
                                  BorrowedLentSection(
                                    title: "Lended",
                                    icon: Icons.trending_up_outlined,
                                    total:
                                        double.tryParse(
                                          lendedController.text,
                                        ) ??
                                        0,
                                    transactions: lendedList,
                                    onAddPressed: () =>
                                        _openExpensePopup("lended"),
                                    onEdit: (txn) => _editTransaction(txn),
                                    onDelete: (txn) => _deleteTransaction(txn),
                                    accent: Colors.green,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last edited on:",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontSize: 12,
                            ),
                          ),
                          Text(lastEditedOn, style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: CustomButton(
                          label: "Save",
                          onPressed: saveUserDetails,
                          color: Colors.deepPurpleAccent.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Note: ",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Expenses added before last edited on date will not effect the fields mentioned here.. only new entries will change the entries here",
                          style: TextStyle(fontSize: 10),
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isExpensePopupOpen,
              child: ExpenseEntryPopup(
                userName: _userDetailsProvider.user?.name ?? "",
                transactionToEdit: txn,
                callBack: (success) async {
                  Navigator.pop(context);
                  if (success) {
                    txn = null;
                    await _loadUserDetails();
                    await _loadTransactionLists();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
