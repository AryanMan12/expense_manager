import 'package:flutter/material.dart';

class OverviewScrollTile extends StatelessWidget {
  final double balance;
  final double totalSpent;
  final int totalTransactions;
  final double totalBorrowed;
  final double totalLent;
  final double totalSavings;
  final double totalInvested;

  final void Function(String type) onTap;

  const OverviewScrollTile({
    super.key,
    required this.balance,
    required this.totalSpent,
    required this.totalTransactions,
    required this.totalBorrowed,
    required this.totalLent,
    required this.totalSavings,
    required this.totalInvested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardItems = [
      _buildTile(
        label: "📥 Borrowed",
        value: "₹${totalBorrowed.toStringAsFixed(2)}",
        type: "borrowed",
        bgColor: Colors.redAccent.withValues(alpha: 0.08),
        textColor: Colors.red[800],
      ),
      _buildTile(
        label: "📤 Lent",
        value: "₹${totalLent.toStringAsFixed(2)}",
        type: "lent",
        bgColor: Colors.greenAccent.withValues(alpha: 0.08),
        textColor: Colors.green[800],
      ),
      _buildTile(
        label: "🏦 Savings",
        value: "₹${totalSavings.toStringAsFixed(2)}",
        type: "savings",
        bgColor: Colors.blueAccent.withValues(alpha: 0.08),
        textColor: Colors.blue[800],
      ),
      _buildTile(
        label: "📈 Invested",
        value: "₹${totalInvested.toStringAsFixed(2)}",
        type: "investments",
        bgColor: Colors.purpleAccent.withValues(alpha: 0.08),
        textColor: Colors.purple[800],
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: cardItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) => cardItems[index],
      ),
    );
  }

  Widget _buildTile({
    required String label,
    required String value,
    required String type,
    required Color bgColor,
    required Color? textColor,
  }) {
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const Spacer(),
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
      ),
    );
  }
}
