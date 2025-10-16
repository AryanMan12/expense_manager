import 'package:expense_manager/database/users_database.dart';
import 'package:expense_manager/models/database_models/users_db_model.dart';
import 'package:expense_manager/widgets/custom_buttons/cusstom_button.dart';
import 'package:expense_manager/widgets/custom_inputs/custom_text_box.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';

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

    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final userService = UserDBService();
    final users = await userService.getAll();

    if (users.isNotEmpty) {
      final user = users.first;

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

    final userService = UserDBService();
    final now = DateTime.now().toString();

    // You can either update the first user, or create a new one
    final existingUsers = await userService.getAll();
    final isUpdating = existingUsers.isNotEmpty;

    final user = UserModel(
      id: isUpdating ? existingUsers.first.id : null,
      name: usernameController.text.trim(),
      total: double.tryParse(currentBalanceController.text.trim()) ?? 0.0,
      savings: double.tryParse(savingsController.text.trim()) ?? 0.0,
      invested: double.tryParse(investmentController.text.trim()) ?? 0.0,
      moneyBorrowed: double.tryParse(borrowedController.text.trim()) ?? 0.0,
      moneyLend: double.tryParse(lendedController.text.trim()) ?? 0.0,
      dailyLimit: 0.0,
      moneyLeftFromDaily: 0.0,
      createdDate: isUpdating ? existingUsers.first.createdDate : now,
      modifiedDate: now,
      isActive: true,
    );

    if (isUpdating) {
      await userService.update(user);
    } else {
      await userService.insert(user);
    }

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
      body: Column(
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
                    inputType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  CustomTextBox(
                    hintText: "Savings",
                    controller: savingsController,
                    icon: Icons.savings_rounded,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  CustomTextBox(
                    hintText: "Investment",
                    controller: investmentController,
                    icon: Icons.waterfall_chart_rounded,
                    inputType: TextInputType.numberWithOptions(decimal: true),
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
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentGeometry.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomButton(
                label: "Save",
                onPressed: saveUserDetails,
                color: Colors.deepPurpleAccent.shade400,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
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
    );
  }
}
