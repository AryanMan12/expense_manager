import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  final double totalAmount;
  final int totalTransactions;
  final int borrowLendTransactions;

  const OverviewCard({
    super.key,
    required this.totalAmount,
    required this.totalTransactions,
    required this.borrowLendTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.money, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  "Total Spent: ₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.list, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  "Total Transactions: $totalTransactions",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.orange),
                const SizedBox(width: 10),
                Text(
                  "Borrow/Lend Transactions: $borrowLendTransactions",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
