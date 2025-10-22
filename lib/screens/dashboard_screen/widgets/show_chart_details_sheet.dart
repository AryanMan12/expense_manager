import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showDetailsBottomSheet(
  BuildContext context,
  Map<String, dynamic> selectedCategory,
  List<Map<String, dynamic>> recentTransactions,
  BoolCallback onCompleteCallback,
  ExpenseCategoryProvider categoryProvider,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final categoryName = selectedCategory['category'] as String? ?? '';
      final date = selectedCategory['date'] != null
          ? DateFormat('dd MMM yyyy').format(selectedCategory['date'])
          : '';
      final totalSpent = (selectedCategory['total'] as double?) ?? 0.0;

      return Padding(
        padding: MediaQuery.of(
          context,
        ).viewInsets, // For keyboard padding if needed
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          height:
              MediaQuery.of(context).size.height * 0.6, // 60% of screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Icon + Category Title + Total Spent
              Row(
                children: [
                  categoryName != ''
                      ? categoryProvider.getIconWidget(
                          categoryProvider.getCategoryIconByName(categoryName),
                          size: 36,
                        )
                      : Text('📈', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoryName != ''
                          ? categoryName
                          : "Transactions on\n$date",
                      style: TextStyle(
                        fontSize: categoryName != '' ? 24 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "\$${totalSpent.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3️⃣ Add chart snippet here — simple example with a placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Chart snippet goes here',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4️⃣ Show recent transactions in this category
              Text(
                'Recent Transactions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 100, // fixed height for transactions list
                child: recentTransactions.isEmpty
                    ? Center(child: Text('No transactions yet.'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentTransactions.length,
                        separatorBuilder: (_, _) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final tx = recentTransactions[index];
                          return Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['title'] ?? 'Untitled',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "\$${(tx['amount'] as double).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  tx['date'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // 5️⃣ “View Details” button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to detailed page for category
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         CategoryDetailsPage(categoryName: categoryName),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('View Details', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() => onCompleteCallback(true));
}
