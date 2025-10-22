// Build Insights Section (e.g., Most Expensive Category, Trends)
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:flutter/material.dart';

Widget buildInsights(
  Map<int, double> expensesByCategory,
  ExpenseCategoryProvider categoryProvider,
) {
  final mostExpensiveCategory = expensesByCategory.entries.isNotEmpty
      ? expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b)
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (mostExpensiveCategory != null) ...[
        Text(
          'Most Expensive Category: ${categoryProvider.getCategoryNameById(mostExpensiveCategory.key)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Total: \$${mostExpensiveCategory.value.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.green),
        ),
      ],
      SizedBox(height: 12),
      Text(
        'Month-over-Month Trend (if applicable)',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 6),
      Text(
        'This section could provide insights such as comparing current month spending with the previous month, or give user tips based on spending habits.',
      ),
    ],
  );
}

// Build Summary Cards for Total Spent, Borrowed, Lent
Widget buildSummaryCard(String title, double amount) {
  return Expanded(
    child: Card(
      child: ListTile(
        title: Text('\$${amount.toStringAsFixed(2)}'),
        subtitle: Text(title),
      ),
    ),
  );
}
