import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/database/user_transactions_database.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends StatelessWidget {
  final UserTransactionModel transaction;
  final String groupName;
  final VoidCallback onRefresh;
  final String userName;
  final VoidCallback onEditClicked;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.userName,
    required this.onRefresh,
    required this.onEditClicked,
    required this.groupName,
  });

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Transaction"),
              onTap: () {
                Navigator.of(context).pop();
                onEditClicked();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete Transaction"),
              onTap: () async {
                Navigator.of(context).pop();
                final dbService = UserTransactionsDBService();
                await dbService.delete(transaction.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction deleted successfully')),
                  );
                }
                onRefresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBorrowed =
        transaction.isBorrowedOrLended == 1 &&
        transaction.payerName != userName;
    final bool isLent =
        transaction.isBorrowedOrLended == 1 &&
        transaction.payerName == userName;

    final bool isIncome =
        transaction.receiverName == userName &&
        transaction.payerName != userName &&
        transaction.isBorrowedOrLended == 2;

    final String formattedDate = transaction.expenseDate != null
        ? DateFormat(
            'd MMM yyyy',
          ).format(DateTime.parse(transaction.expenseDate!))
        : '';

    // Amount color based on transaction type
    final Color amountColor = isIncome || isBorrowed
        ? Colors.green[800]!
        : Colors.red[800]!;

    return GestureDetector(
      onLongPress: () => _showActionSheet(context),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: isIncome || isBorrowed
                ? Colors.green[100]
                : Colors.red[100],
            child: Icon(Icons.currency_rupee, color: amountColor),
          ),
          title: Text(
            transaction.payerName == transaction.receiverName
                ? "On Self"
                : "${transaction.payerName} → ${transaction.receiverName}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.description != null &&
                  transaction.description!.trim().isNotEmpty)
                Text(
                  transaction.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),

              Text(
                "Group: $groupName",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),

              // Date Emphasis
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.deepPurple[300],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹${transaction.amount?.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              if (isBorrowed || isLent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isBorrowed ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBorrowed ? Icons.call_received : Icons.call_made,
                        size: 12,
                        color: isBorrowed ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBorrowed ? "Borrowed" : "Lent",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isBorrowed ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
