import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:expense_manager/models/database_models/user_transactions_db_model.dart';
import 'package:expense_manager/utils/constants.dart';
import 'package:expense_manager/utils/date_utils.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:expense_manager/widgets/custom_buttons/cusstom_button.dart';
import 'package:expense_manager/widgets/custom_checkbox/custom_checkbox.dart';
import 'package:expense_manager/widgets/custom_dropdown/custom_dropdown.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_date_time_picker.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_area.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_box.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_popup_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    expenseDateController = TextEditingController(
      text: widget.transactionToEdit?.expenseDate ?? getCurrentUIDateTime(),
    );

    // Set the expense group if editing
    selectedExpenseGroup = ListOfExpenses.getExpenseName(
      widget.transactionToEdit?.expenseGroupId ?? 1,
    );

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

  // Save function
  Future<void> saveTransaction() async {
    if (!validateFields()) return;

    // Ensure expenseDateController is in ISO 8601 format
    String expenseDate = expenseDateController.text.trim();
    try {
      DateTime parsedExpenseDate = DateFormat(
        uiDateTimeFormat,
      ).parse(expenseDate);
      expenseDate = parsedExpenseDate.toIso8601String();
    } catch (e) {
      // If the date format is incorrect, show an error
      showErrorDialog("Invalid date format. Please enter a valid date.");
      return;
    }

    // Create the UserTransactionModel from the form data
    final userTransaction = UserTransactionModel(
      id: widget.transactionToEdit?.id,
      payerName: fromController.text.trim(),
      receiverName: toController.text.trim(),
      amount: double.tryParse(amountController.text),
      description: descController.text,
      expenseGroupId: ListOfExpenses.getExpenseId(selectedExpenseGroup),
      eventId: 1, // Example event ID, modify as needed
      splitTransactionId: null,
      isBorrowedOrLended: isBorrowedOrLended ? 1 : 2,
      expenseDate: expenseDate,
      createdDate:
          widget.transactionToEdit?.createdDate ??
          DateTime.now().toIso8601String(),
      modifiedDate: DateTime.now().toIso8601String(),
    );

    // Call the database service to insert the transaction
    final dbService = UserTransactionsDBService();
    try {
      if (userTransaction.id != null) {
        await dbService.update(userTransaction);
      } else {
        await dbService.insert(userTransaction);
      }
      widget.callBack(true);
    } catch (e) {
      print(e);
      showErrorDialog("Failed to save transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Center(
      child: Container(
        height: screenSize.height * 0.6,
        width: screenSize.width * 0.9,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(128),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(3, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomPopupHeader(headerText: "Add Transaction", isVisible: false),
            const SizedBox(height: 5),
            Expanded(
              child: ListView(
                children: [
                  CustomTextBox(
                    hintText: "Amount",
                    controller: amountController,
                    icon: Icons.currency_rupee,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextBox(
                          hintText: "From",
                          controller: fromController,
                          icon: Icons.person_outline_rounded,
                          onChange: (callback) => setState(() {}),
                        ),
                      ),
                      // Interchange IconButton
                      InkWell(
                        onTap: swapText,
                        child: Icon(Icons.swap_horiz, size: 24),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: CustomTextBox(
                          hintText: "To",
                          controller: toController,
                          icon: Icons.person_outline_rounded,
                          onChange: (callback) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible:
                        fromController.text.trim() != toController.text.trim(),
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        CustomCheckboxField(
                          label: fromController.text.trim() == widget.userName
                              ? "Lend"
                              : "Borrowed",
                          value: isBorrowedOrLended,
                          onChanged: (val) => setState(
                            () => isBorrowedOrLended = !isBorrowedOrLended,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomDropdownField(
                    hintText: "Expense Group",
                    icon: Icons.food_bank,
                    items: ListOfExpenses.listOfExpenses,
                    selectedValue: selectedExpenseGroup,
                    onChanged: (val) =>
                        setState(() => selectedExpenseGroup = val),
                  ),
                  const SizedBox(height: 5),
                  CustomDateTimePicker(
                    hintText: "Select Expense Date",
                    controller: expenseDateController,
                    onChange: (callback) => setState(() {}),
                  ),
                  const SizedBox(height: 5),
                  CustomTextArea(
                    hintText: "Description",
                    controller: descController,
                    icon: Icons.description,
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: SizedBox()),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    label: "Cancel",
                    onPressed: () {
                      widget.callBack(true);
                    },
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    label: "Save",
                    onPressed: () async {
                      await saveTransaction();
                    },
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
