import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';

class ListOfExpenseGroupScreen extends StatelessWidget {
  const ListOfExpenseGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader(
            screenName: "Expense Groups",
            hasBack: true,
            onBackClick: (callback) {
              if (!callback) return;
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
