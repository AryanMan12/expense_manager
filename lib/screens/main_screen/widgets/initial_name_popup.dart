import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showNameInputDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController savingsController = TextEditingController();
  final TextEditingController investedController = TextEditingController();
  final TextEditingController borrowedController = TextEditingController();
  final TextEditingController lendController = TextEditingController();

  bool showMore = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Setup Your Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name input
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Initial balance
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Initial Total Balance',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      hintText: 'e.g. 5000',
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Toggle “add more”
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add more details',
                        style: TextStyle(fontSize: 14),
                      ),
                      Switch(
                        value: showMore,
                        onChanged: (val) => setState(() => showMore = val),
                      ),
                    ],
                  ),

                  // Expandable section
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: savingsController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Savings Amount',
                            prefixIcon: Icon(Icons.savings_outlined),
                            hintText: 'e.g. 2000',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: investedController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Invested Amount',
                            prefixIcon: Icon(Icons.trending_up),
                            hintText: 'e.g. 1500',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: borrowedController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Money Borrowed',
                            prefixIcon: Icon(Icons.arrow_downward),
                            hintText: 'e.g. 500',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: lendController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Money Lent',
                            prefixIcon: Icon(Icons.arrow_upward),
                            hintText: 'e.g. 300',
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: showMore
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name')),
                    );
                    return;
                  }

                  double parseOrZero(String val) =>
                      double.tryParse(val.trim()) ?? 0.0;

                  final total = parseOrZero(totalController.text);
                  final savings = showMore
                      ? parseOrZero(savingsController.text)
                      : 0.0;
                  final invested = showMore
                      ? parseOrZero(investedController.text)
                      : 0.0;
                  final borrowed = showMore
                      ? parseOrZero(borrowedController.text)
                      : 0.0;
                  final lend = showMore
                      ? parseOrZero(lendController.text)
                      : 0.0;

                  final newUser = UserModel(
                    id: 1,
                    name: name,
                    total: total,
                    savings: savings,
                    invested: invested,
                    dailyLimit: 0.0,
                    moneyLeftFromDaily: 0.0,
                    moneyBorrowed: borrowed,
                    moneyLend: lend,
                    createdDate: DateTime.now().toIso8601String(),
                    modifiedDate: DateTime.now().toIso8601String(),
                    isActive: true,
                  );

                  Provider.of<UserDetailsProvider>(
                    context,
                    listen: false,
                  ).updateUserDetails(newUser);

                  Navigator.of(dialogCtx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
