import 'package:flutter/material.dart';

class OverviewFixedTopCards extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalSpent;
  final int totalTransactions;

  const OverviewFixedTopCards({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalSpent,
    required this.totalTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCard(
            title: "💰 Balance",
            value: "₹${balance.toStringAsFixed(2)}",
            color: Colors.greenAccent.withValues(alpha: 0.1),
            textColor: Colors.green[800],
          ),
          const SizedBox(width: 8),
          _buildCard(
            title: "🟢 Income",
            value: "₹${totalIncome.toStringAsFixed(2)}",
            color: Colors.tealAccent.withValues(alpha: 0.1),
            textColor: Colors.teal[800],
          ),
          const SizedBox(width: 8),
          _buildCard(
            title: "🧾 Spent",
            value: "₹${totalSpent.toStringAsFixed(2)}",
            color: Colors.redAccent.withValues(alpha: 0.1),
            textColor: Colors.red[800],
          ),
          const SizedBox(width: 8),
          _buildCard(
            title: "📊 Transactions",
            value: "$totalTransactions",
            color: Colors.blueAccent.withValues(alpha: 0.1),
            textColor: Colors.blue[800],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
    required Color? textColor,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
