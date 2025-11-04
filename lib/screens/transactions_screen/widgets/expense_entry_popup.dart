import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/database/users_database.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:expense_manager/widgets/custom_checkbox/custom_checkbox.dart';
import 'package:expense_manager/widgets/custom_dropdown/custom_dropdown.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_area.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseEntryPopup extends StatefulWidget {
  final BoolCallback callBack;
  final String userName;
  final UserTransactionModel? transactionToEdit;
  const ExpenseEntryPopup({
    super.key,
    required this.callBack,
    required this.userName,
    this.transactionToEdit,
  });

  @override
  State<ExpenseEntryPopup> createState() => _ExpenseEntryPopupState();
}

class _ExpenseEntryPopupState extends State<ExpenseEntryPopup>
    with TickerProviderStateMixin {
  late TextEditingController amountController;
  late TextEditingController descController;
  late TextEditingController toController;
  late TextEditingController expenseDateController;

  late UserDetailsProvider _userDetailsProvider;
  late ExpenseCategoryProvider _categoryProvider;

  late String _uiDate;
  late String _uiTime;

  late TabController _tabController;

  DateTime? selectedExpenseDateTime;

  int? selectedSubCategoryId;
  int currentTabIndex = 0;
  String? selectedSubCategoryName;

  String? selectedExpenseGroup;

  bool isBorrowedOrLended = false;
  bool isExpenseTab = true;

  @override
  void initState() {
    super.initState();

    _initializeControllers();
    _initializeProviders();
    _initializeTabController();
    _handleEditMode();
    _fetchCategoriesAndSubcategories();
    _initializeDateTime();
    _initializeExpenseGroup();

    // Set Borrowed/Lended flag
    isBorrowedOrLended = widget.transactionToEdit?.isBorrowedOrLended == 1;
  }

  void _initializeControllers() {
    amountController = TextEditingController(
      text: widget.transactionToEdit?.amount.toString() ?? '',
    );
    descController = TextEditingController(
      text: widget.transactionToEdit?.description ?? '',
    );
    toController = TextEditingController();
    expenseDateController = TextEditingController();
  }

  void _initializeProviders() {
    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );
    _categoryProvider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );
  }

  void _initializeTabController() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        currentTabIndex = _tabController.index;
        _updateNameFieldForTab();
      });
    });

    // Default tab = Expense
    currentTabIndex = 0;
    _updateNameFieldForTab();
  }

  void _handleEditMode() {
    final t = widget.transactionToEdit;
    if (t == null) return;

    // Determine current tab (Expense / Income)
    if (t.payerName == widget.userName) {
      currentTabIndex = 0; // Expense
      isExpenseTab = true;
    } else {
      currentTabIndex = 1; // Income
      isExpenseTab = false;
    }

    _tabController.index = currentTabIndex;

    // Update "to" field
    toController.text = (t.payerName == widget.userName)
        ? (t.receiverName ?? "")
        : (t.payerName ?? "");
  }

  Future<void> _fetchCategoriesAndSubcategories() async {
    await _categoryProvider.fetchCategories();

    for (var cat in _categoryProvider.categories) {
      await _categoryProvider.fetchSubCategories(cat.id!);
    }

    // If editing, find and set selected subcategory
    final subId = widget.transactionToEdit?.expenseSubGroupId;
    if (subId == null) return;

    for (var cat in _categoryProvider.categories) {
      final sub = _categoryProvider
          .subCategoriesForCategory(cat.id!)
          .firstWhere(
            (s) => s.id == subId,
            orElse: () => ExpenseSubCategoryModel(),
          );

      if (sub.id != null) {
        setState(() {
          selectedSubCategoryId = sub.id;
          selectedSubCategoryName = sub.name;
        });
        break;
      }
    }
  }

  void _initializeDateTime() {
    final now = widget.transactionToEdit?.expenseDate != null
        ? DateTime.parse(widget.transactionToEdit!.expenseDate!)
        : DateTime.now();

    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);

    _uiDate = formattedDate;
    _uiTime = formattedTime;
    selectedExpenseDateTime = now;

    expenseDateController.text = "$formattedDate\n$formattedTime";
  }

  void _initializeExpenseGroup() {
    selectedExpenseGroup = widget.transactionToEdit?.expenseGroupId != null
        ? _categoryProvider.getCategoryNameById(
            widget.transactionToEdit!.expenseGroupId,
          )
        : "All";
  }

  void _updateNameFieldForTab() {
    toController.text = currentTabIndex == 0 ? "Myself" : "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    amountController.dispose();
    descController.dispose();
    toController.dispose();
    expenseDateController.dispose();
  }

  void _handleAddNewSubCategory(String newSubName) async {
    if (newSubName.trim().isEmpty) return;

    final selectedCategoryId = _categoryProvider.getCategoryIdByName(
      selectedExpenseGroup ?? '',
    );
    if (selectedCategoryId == null || selectedExpenseGroup == "All") {
      showErrorDialog("Please select a category before adding a subcategory.");
      return;
    }

    final newSub = ExpenseSubCategoryModel(
      name: newSubName.trim(),
      categoryId: selectedCategoryId,
    );

    await _categoryProvider.addSubCategory(newSub);

    await _categoryProvider.fetchSubCategories(selectedCategoryId);

    setState(() {
      selectedSubCategoryName = newSubName;
      selectedSubCategoryId = _categoryProvider
          .subCategoriesForCategory(selectedCategoryId)
          .firstWhere((s) => s.name == newSubName)
          .id;
    });
  }

  // Validate fields
  bool validateFields() {
    amountController.text = amountController.text.trim();
    toController.text = toController.text.trim();
    descController.text = descController.text.trim();
    if (amountController.text.isEmpty) {
      showErrorDialog("Amount is required");
      return false;
    }

    if (double.tryParse(amountController.text) == null) {
      showErrorDialog("Enter a valid amount");
      return false;
    }

    if (isExpenseTab) {
      // Expense: "Spent on" can be empty, default to "Myself"
      if (toController.text.trim().isEmpty) {
        toController.text = widget.userName;
      }
    } else {
      // Income: must have a valid name, not yourself
      if (toController.text.trim().isEmpty) {
        showErrorDialog("Please enter who you earned from");
        return false;
      }
      if (toController.text.trim().toLowerCase() ==
          widget.userName.trim().toLowerCase()) {
        showErrorDialog("Name cannot be your own for Income");
        return false;
      }
    }

    if (selectedExpenseDateTime == null) {
      showErrorDialog("Please select a valid date and time");
      return false;
    }

    if (selectedSubCategoryId == null) {
      showErrorDialog("Please select a Subcategory");
      return false;
    }

    return true;
  }

  // Show an error dialog (could be a custom widget or AlertDialog)
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<UserModel> ensureUserExists(String name) async {
    final userDB = UserDBService();
    final existingUser = await userDB.getByName(name.trim());
    if (existingUser != null) return existingUser;

    final nowIso = DateTime.now().toIso8601String();

    final newUser = UserModel(
      name: name.trim(),
      total: 0.0,
      savings: 0.0,
      invested: 0.0,
      dailyLimit: 0.0,
      moneyLeftFromDaily: 0.0,
      moneyBorrowed: 0.0,
      moneyLend: 0.0,
      isActive: true,
      createdDate: nowIso,
      modifiedDate: nowIso,
    );

    final newId = await userDB.insert(newUser);
    return newUser.copyWith(id: newId);
  }

  // Save function
  Future<void> saveTransaction() async {
    if (!validateFields()) return;

    try {
      final dbService = UserTransactionsDBService();
      final userDB = UserDBService();

      final userName = _resolveUserName();
      final toUser = await ensureUserExists(userName);
      final mainUser = _userDetailsProvider.user!;

      final transaction = _buildTransaction(toUser);
      await _saveOrUpdateTransaction(dbService, transaction);

      final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
      await _updateUserTotals(userDB, mainUser, toUser, amount);

      await _userDetailsProvider.updateUserDetails(mainUser);
      widget.callBack(true);
    } catch (e, s) {
      log('saveTransaction error: $e\n$s');
      showErrorDialog("Failed to save transaction: $e");
    }
  }

  String _resolveUserName() {
    final name = toController.text.trim();
    return name.toLowerCase() == "myself" ? widget.userName : name;
  }

  UserTransactionModel _buildTransaction(UserModel toUser) {
    final nowIso = DateTime.now().toIso8601String();
    final edit = widget.transactionToEdit;

    return UserTransactionModel(
      id: edit?.id,
      payerName: currentTabIndex == 0 ? widget.userName : toUser.name,
      receiverName: currentTabIndex == 1 ? widget.userName : toUser.name,
      amount: double.tryParse(amountController.text),
      description: descController.text,
      expenseGroupId: _categoryProvider.getCategoryIdByName(
        selectedExpenseGroup ?? "All",
      ),
      expenseSubGroupId: selectedSubCategoryId,
      eventId: 1,
      splitTransactionId: null,
      isBorrowedOrLended: isBorrowedOrLended ? 1 : 2,
      expenseDate: selectedExpenseDateTime?.toIso8601String() ?? nowIso,
      createdDate: edit?.createdDate ?? nowIso,
      modifiedDate: nowIso,
    );
  }

  Future<void> _saveOrUpdateTransaction(
    UserTransactionsDBService dbService,
    UserTransactionModel txn,
  ) async {
    if (txn.id != null) {
      await dbService.update(txn);
    } else {
      await dbService.insert(txn);
    }
  }

  Future<void> _updateUserTotals(
    UserDBService userDB,
    UserModel mainUser,
    UserModel targetUser,
    double amount,
  ) async {
    final nowIso = DateTime.now().toIso8601String();

    if (isExpenseTab) {
      // Expense: money spent
      await userDB.update(
        targetUser.copyWith(
          total: (targetUser.total ?? 0) + amount,
          modifiedDate: nowIso,
        ),
      );
      mainUser = mainUser.copyWith(
        total: (mainUser.total ?? 0) - amount,
        modifiedDate: nowIso,
      );
    } else {
      // Income: money earned
      await userDB.update(
        targetUser.copyWith(
          total: (targetUser.total ?? 0) - amount,
          modifiedDate: nowIso,
        ),
      );
      mainUser = mainUser.copyWith(
        total: (mainUser.total ?? 0) + amount,
        modifiedDate: nowIso,
      );
    }
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GestureDetector(
        onTap: () async {
          final now = DateTime.now();

          final pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate == null) return;
          if (mounted) {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(now),
            );

            if (pickedTime == null) return;

            final fullDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            final formattedDate = DateFormat(
              'dd MMM yyyy',
            ).format(fullDateTime);
            final formattedTime = DateFormat('hh:mm a').format(fullDateTime);

            setState(() {
              expenseDateController.text = "$formattedDate\n$formattedTime";
              selectedExpenseDateTime = fullDateTime;
              _uiDate = formattedDate;
              _uiTime = formattedTime;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _uiDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _uiTime,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 500;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: size.height * (isSmall ? 0.8 : 0.6),
        width: size.width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.deepPurple.shade50,
              Colors.indigo.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade100.withValues(alpha: .3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildGradientTabs(),
            const SizedBox(height: 16),

            // Split view instead of long list
            Expanded(
              child: isSmall
                  ? _buildVerticalForm() // mobile layout
                  : _buildSplitForm(), // desktop/tablet layout
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientTabs() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.deepPurple.shade400,
        tabs: const [
          Tab(text: "Expense"),
          Tab(text: "Income"),
        ],
      ),
    );
  }

  Widget _buildSplitForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT PANEL
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildCategorySelectors(),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // RIGHT PANEL
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFromToField(),
              const SizedBox(height: 12),
              if (toController.text.trim() != "Myself")
                CustomCheckboxField(
                  label: currentTabIndex == 0 ? "Lend" : "Borrowed",
                  value: isBorrowedOrLended,
                  onChanged: (v) =>
                      setState(() => isBorrowedOrLended = !isBorrowedOrLended),
                ),
              const SizedBox(height: 12),
              _buildDescriptionField(),
              const Spacer(),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalForm() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 16),
        _buildAmountField(),
        const SizedBox(height: 16),
        _buildCategorySelectors(),
        const SizedBox(height: 16),
        _buildFromToField(),
        if (toController.text.trim() != "Myself")
          CustomCheckboxField(
            label: currentTabIndex == 0 ? "Lend" : "Borrowed",
            value: isBorrowedOrLended,
            onChanged: (v) =>
                setState(() => isBorrowedOrLended = !isBorrowedOrLended),
          ),
        const SizedBox(height: 16),
        _buildDescriptionField(),
        _buildActionButtons(),
      ],
    );
  }

  //
  // ─── HEADER ROW (TITLE + DATE PICKER) ───────────────────────────────────────
  //
  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.transactionToEdit == null
                ? "Add Transaction"
                : "Edit Transaction",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
        ),
        _buildDatePicker(),
      ],
    );
  }

  //
  // ─── AMOUNT FIELD (PROMINENT CENTERED) ──────────────────────────────────────
  //
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: SizedBox(
          width: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: CustomTextBox(
                hintText: "₹0.00",
                controller: amountController,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                textStyle: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                helperText: "Amount",
                textAlign: TextAlign.center,
                autoFocus: true,
                hideBorder: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //
  // ─── FROM / TO FIELD ────────────────────────────────────────────────────────
  //
  Widget _buildFromToField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CustomTextBox(
        hintText: isExpenseTab ? "Spent on" : "Earned from",
        helperText: isExpenseTab ? "Spent on" : "Earned from",
        controller: toController,
        onChange: (_) => setState(() {}),
      ),
    );
  }

  //
  // ─── CATEGORY + SUBCATEGORY SELECTORS ───────────────────────────────────────
  //
  Widget _buildCategorySelectors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          CustomDropdownBox(
            hintText: "Category",
            items: ["All", ..._categoryProvider.categoryNames],
            selectedValue: selectedExpenseGroup,
            showFloatingHint: true,
            onChanged: (val) {
              setState(() {
                selectedExpenseGroup = val;
                selectedSubCategoryName = null;
                selectedSubCategoryId = null;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildSubCategoryDropdown(),
        ],
      ),
    );
  }

  //
  // ─── SUBCATEGORY DROPDOWN ──────────────────────────────────────────────────
  //
  Widget _buildSubCategoryDropdown() {
    return DropdownSearch<String>(
      dropdownBuilder: (context, selectedItem) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            selectedItem ?? "Select Subcategory",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: selectedItem == null ? Colors.grey : Colors.black,
            ),
          ),
        );
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search subcategory...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        emptyBuilder: (context, searchEntry) {
          if (searchEntry.isNotEmpty) {
            return ListTile(
              title: Text("Add '$searchEntry' as new subcategory"),
              onTap: () async {
                final trimmedName = searchEntry.trim().toLowerCase();
                final allSubs = _categoryProvider.categories
                    .expand(
                      (cat) =>
                          _categoryProvider.subCategoriesForCategory(cat.id!),
                    )
                    .toList();

                final exists = allSubs.any(
                  (sub) => sub.name?.trim().toLowerCase() == trimmedName,
                );

                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Subcategory '$searchEntry' already exists.",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                _handleAddNewSubCategory(searchEntry);
              },
            );
          }

          return const Center(child: Text("No matching subcategories"));
        },
      ),
      items: (String filter, LoadProps? loadProps) async {
        List<ExpenseSubCategoryModel> filteredSubs = [];

        if (selectedExpenseGroup != null && selectedExpenseGroup != "All") {
          final categoryId = _categoryProvider.getCategoryIdByName(
            selectedExpenseGroup!,
          );
          if (categoryId != null) {
            filteredSubs = _categoryProvider.subCategoriesForCategory(
              categoryId,
            );
          }
        } else {
          filteredSubs = _categoryProvider.categories
              .expand(
                (cat) => _categoryProvider.subCategoriesForCategory(cat.id!),
              )
              .toList();
        }

        final names = filteredSubs.map((s) => s.name!).toSet().toList();
        if (filter.isEmpty) return names;

        final lower = filter.toLowerCase();
        return names.where((n) => n.toLowerCase().contains(lower)).toList();
      },
      selectedItem: selectedSubCategoryName,
      onChanged: (subName) {
        if (subName == null) return;
        setState(() {
          selectedSubCategoryName = subName;
          for (var cat in _categoryProvider.categories) {
            final found = _categoryProvider
                .subCategoriesForCategory(cat.id!)
                .firstWhere(
                  (s) => s.name == subName,
                  orElse: () => ExpenseSubCategoryModel(),
                );
            if (found.id != null) {
              selectedExpenseGroup = cat.name;
              selectedSubCategoryId = found.id;
              break;
            }
          }
        });
      },
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }

  //
  // ─── DESCRIPTION FIELD ─────────────────────────────────────────────────────
  //
  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CustomTextArea(
        hintText: "Description (optional)",
        controller: descController,
        icon: Icons.description_outlined,
      ),
    );
  }

  //
  // ─── ACTION BUTTONS (SAVE / CANCEL) ─────────────────────────────────────────
  //
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => widget.callBack(true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async => await saveTransaction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
