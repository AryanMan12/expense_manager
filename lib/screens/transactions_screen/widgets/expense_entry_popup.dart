import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/database/users_database.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/utils/date_utils.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:expense_manager/widgets/custom_buttons/cusstom_button.dart';
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

class _ExpenseEntryPopupState extends State<ExpenseEntryPopup> {
  late TextEditingController amountController;
  late TextEditingController descController;
  late TextEditingController fromController;
  late TextEditingController toController;
  late TextEditingController expenseDateController;

  late UserDetailsProvider _userDetailsProvider;
  late ExpenseCategoryProvider _categoryProvider;

  late String _uiDate;
  late String _uiTime;

  DateTime? selectedExpenseDateTime;

  int? selectedSubCategoryId;
  String? selectedSubCategoryName;

  String? selectedExpenseGroup;

  bool isBorrowedOrLended = false;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    descController = TextEditingController();
    fromController = TextEditingController();
    toController = TextEditingController();
    expenseDateController = TextEditingController();

    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );

    _categoryProvider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );

    _categoryProvider.fetchCategories().then((_) async {
      for (var cat in _categoryProvider.categories) {
        await _categoryProvider.fetchSubCategories(cat.id!);
      }

      if (widget.transactionToEdit != null) {
        final subId = widget.transactionToEdit!.expenseSubGroupId;
        if (subId != null) {
          // Find the subcategory by ID
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
      }
    });

    // Initialize controllers with the transaction data if editing
    amountController = TextEditingController(
      text: widget.transactionToEdit?.amount.toString() ?? '',
    );
    descController = TextEditingController(
      text: widget.transactionToEdit?.description ?? '',
    );
    fromController = TextEditingController(
      text: widget.transactionToEdit?.payerName ?? widget.userName,
    );
    toController = TextEditingController(
      text: widget.transactionToEdit?.receiverName ?? widget.userName,
    );
    final now = widget.transactionToEdit?.expenseDate != null
        ? DateTime.parse(widget.transactionToEdit!.expenseDate!)
        : DateTime.now();

    _uiDate = DateFormat('dd MMM yyyy').format(now);
    _uiTime = DateFormat('hh:mm a').format(now);
    expenseDateController = TextEditingController(
      text: "$formattedDate\n$formattedTime",
    );
    selectedExpenseDateTime = now;

    selectedExpenseGroup = widget.transactionToEdit?.expenseGroupId != null
        ? _categoryProvider.getCategoryNameById(
            widget.transactionToEdit?.expenseGroupId,
          )
        : "All";

    isBorrowedOrLended = widget.transactionToEdit?.isBorrowedOrLended == 1;
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    descController.dispose();
    fromController.dispose();
    toController.dispose();
    expenseDateController.dispose();
  }

  // Method to swap the text between controllers
  void swapText() {
    setState(() {
      String temp = fromController.text;
      fromController.text = toController.text;
      toController.text = temp;
    });
  }

  // Validate fields
  bool validateFields() {
    amountController.text = amountController.text.trim();
    fromController.text = fromController.text.trim();
    toController.text = toController.text.trim();
    descController.text = descController.text.trim();

    if (amountController.text.isEmpty) {
      // Amount cannot be empty
      showErrorDialog("Amount is required");
      return false;
    }

    if (double.tryParse(amountController.text) == null) {
      // Amount should be a valid number
      showErrorDialog("Enter a valid amount");
      return false;
    }

    if (fromController.text.isEmpty || toController.text.isEmpty) {
      // From and To fields are required
      showErrorDialog("Both From and To are required");
      return false;
    }

    if (expenseDateController.text.isEmpty) {
      // Date is required
      showErrorDialog("Expense date is required");
      return false;
    }

    if (selectedExpenseDateTime == null) {
      showErrorDialog("Please select a valid date and time");
      return false;
    }

    if (selectedSubCategoryId == null) {
      showErrorDialog("Please select a Subcategory");
      return false;
    }

    if (selectedExpenseGroup == null || selectedExpenseGroup!.isEmpty) {
      // Expense group should be selected
      showErrorDialog("Please select an Expense Group");
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
    final existing = await userDB.getByName(name);
    if (existing != null) return existing;

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
      createdDate: DateTime.now().toIso8601String(),
      modifiedDate: DateTime.now().toIso8601String(),
    );

    final newId = await userDB.insert(newUser);
    return newUser.copyWith(id: newId);
  }

  // Save function
  Future<void> saveTransaction() async {
    if (!validateFields()) return;

    final dbService = UserTransactionsDBService();
    final userDB = UserDBService();

    try {
      // Ensure both "From" and "To" users exist
      final fromUser = await ensureUserExists(fromController.text.trim());
      final toUser = await ensureUserExists(toController.text.trim());

      // Prepare transaction
      final userTransaction = UserTransactionModel(
        id: widget.transactionToEdit?.id,
        payerName: fromUser.name,
        receiverName: toUser.name,
        amount: double.tryParse(amountController.text),
        description: descController.text,
        expenseGroupId: _categoryProvider.getCategoryIdByName(
          selectedExpenseGroup!,
        ),
        expenseSubGroupId: selectedSubCategoryId,
        eventId: 1,
        splitTransactionId: null,
        isBorrowedOrLended: isBorrowedOrLended ? 1 : 2,
        expenseDate:
            selectedExpenseDateTime?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        createdDate:
            widget.transactionToEdit?.createdDate ??
            DateTime.now().toIso8601String(),
        modifiedDate: DateTime.now().toIso8601String(),
      );

      // Save transaction (insert or update)
      if (userTransaction.id != null) {
        await dbService.update(userTransaction);
      } else {
        await dbService.insert(userTransaction);
      }

      // Update totals
      final mainUser = _userDetailsProvider.user!;
      double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
      UserModel updatedMain = mainUser;

      // CASE 1️⃣: Main user is paying someone (expense)
      if (fromUser.id == mainUser.id) {
        updatedMain = updatedMain.copyWith(
          total: (updatedMain.total ?? 0) - amount,
          moneyLend: (updatedMain.moneyLend ?? 0) + amount,
          modifiedDate: DateTime.now().toIso8601String(),
        );

        // Update the other user's side
        final updatedReceiver = toUser.copyWith(
          total: (toUser.total ?? 0) + amount,
          moneyBorrowed: (toUser.moneyBorrowed ?? 0) + amount,
          modifiedDate: DateTime.now().toIso8601String(),
        );
        await userDB.update(updatedReceiver);
      }
      // CASE 2️⃣: Main user is receiving money
      else if (toUser.id == mainUser.id) {
        updatedMain = updatedMain.copyWith(
          total: (updatedMain.total ?? 0) + amount,
          moneyBorrowed: (updatedMain.moneyBorrowed ?? 0) - amount,
          modifiedDate: DateTime.now().toIso8601String(),
        );

        // Update the payer’s side
        final updatedPayer = fromUser.copyWith(
          total: (fromUser.total ?? 0) - amount,
          moneyLend: (fromUser.moneyLend ?? 0) - amount,
          modifiedDate: DateTime.now().toIso8601String(),
        );
        await userDB.update(updatedPayer);
      }

      // Save main user updates both in DB + provider
      await _userDetailsProvider.updateUserDetails(updatedMain);

      widget.callBack(true);
    } catch (e) {
      log(e.toString());
      showErrorDialog("Failed to save transaction: $e");
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Center(
      child: Container(
        height: screenSize.height * 0.6,
        width: screenSize.width * 0.95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // background gradient or soft color
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade50],
            end: Alignment.topLeft,
            begin: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // 🕒 Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                      ),

                      _buildDatePicker(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🧑 From / To
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextBox(
                          hintText: "From",
                          helperText: "From",
                          controller: fromController,
                          onChange: (callback) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        onPressed: swapText,
                        icon: Icon(Icons.swap_horiz),
                        padding: const EdgeInsets.only(bottom: 12),
                      ),
                      Expanded(
                        child: CustomTextBox(
                          hintText: "To",
                          helperText: "To",
                          controller: toController,
                          onChange: (callback) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  // ☑️ Borrowed / Lended
                  if (fromController.text.trim() != toController.text.trim())
                    CustomCheckboxField(
                      label: fromController.text.trim() == widget.userName
                          ? "Lend"
                          : "Borrowed",
                      value: isBorrowedOrLended,
                      onChanged: (val) => setState(
                        () => isBorrowedOrLended = !isBorrowedOrLended,
                      ),
                    ),

                  // 💰 Amount (centered, large)
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: CustomTextBox(
                        hintText: "₹0.00",
                        controller: amountController,
                        inputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        helperText: "Amount",
                        textAlign: TextAlign.center,
                        autoFocus: true,
                        hideBorder: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  CustomDropdownBox(
                    hintText: "Category",
                    textStyle: TextStyle(overflow: TextOverflow.ellipsis),
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

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: DropdownSearch<String>(
                      dropdownBuilder: (context, selectedItem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            selectedItem ?? "Select Subcategory",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: selectedItem == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                        emptyBuilder: (context, searchEntry) {
                          if (searchEntry.isNotEmpty) {
                            return ListTile(
                              title: Text(
                                "Add '$searchEntry' as new subcategory",
                              ),
                              onTap: () async {
                                final trimmedName = searchEntry
                                    .trim()
                                    .toLowerCase();

                                final allSubcategories = _categoryProvider
                                    .categories
                                    .expand(
                                      (cat) => _categoryProvider
                                          .subCategoriesForCategory(cat.id!),
                                    )
                                    .toList();

                                final exists = allSubcategories.any(
                                  (sub) =>
                                      sub.name?.trim().toLowerCase() ==
                                      trimmedName,
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

                          return const Center(
                            child: Text("No matching subcategories"),
                          );
                        },
                      ),
                      items: (String filter, LoadProps? loadProps) async {
                        List<ExpenseSubCategoryModel> filteredSubs = [];

                        if (selectedExpenseGroup != null &&
                            selectedExpenseGroup != "All") {
                          final selectedCategoryId = _categoryProvider
                              .getCategoryIdByName(selectedExpenseGroup!);
                          if (selectedCategoryId != null) {
                            filteredSubs = _categoryProvider
                                .subCategoriesForCategory(selectedCategoryId);
                          }
                        } else {
                          // "All" selected → show every subcategory
                          filteredSubs = _categoryProvider.categories
                              .expand(
                                (cat) => _categoryProvider
                                    .subCategoriesForCategory(cat.id!),
                              )
                              .toList();
                        }

                        final subNames = filteredSubs
                            .map((s) => s.name!)
                            .toSet()
                            .toList();

                        if (filter.isEmpty) return subNames;

                        final lower = filter.toLowerCase();
                        return subNames
                            .where((name) => name.toLowerCase().contains(lower))
                            .toList();
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
                          // hintText: "Select Subcategory",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomTextArea(
                      hintText: "Description (optional)",
                      controller: descController,
                      icon: Icons.description,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: SizedBox()), // Spacer
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      label: "Cancel",
                      onPressed: () => widget.callBack(true),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      label: "Save",
                      onPressed: () async => await saveTransaction(),
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
