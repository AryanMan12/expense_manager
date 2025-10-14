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

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    currentBalanceController = TextEditingController();
    savingsController = TextEditingController();
    investmentController = TextEditingController();
    borrowedController = TextEditingController();
    lendedController = TextEditingController();
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
                Text(DateTime.now().toString(), style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Note: ", style: TextStyle(fontSize: 10)),
                Expanded(
                  child: Text(
                    "Expenses added before last edited on date will not effect the fields mentioned here.. only new entries will change the entries here",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
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
