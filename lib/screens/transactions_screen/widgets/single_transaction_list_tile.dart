import 'package:expense_manager/utils/constants.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/database_models/user_transactions_db_model.dart';
import 'package:expense_manager/database/user_transactions_database.dart'; // Assuming this contains your DB delete method

class TransactionListTile extends StatelessWidget {
  final UserTransactionModel transaction;
  final VoidCallback onRefresh;
  final String userName;
  final VoidCallback onEditClicked;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.userName,
    required this.onRefresh,
    required this.onEditClicked,
  });

  // Function to show action sheet for edit or delete
  void _showActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit Transaction"),
                onTap: () {
                  Navigator.of(context).pop();
                  _editTransaction(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete Transaction"),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteTransaction(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle the delete operation
  Future<void> _deleteTransaction(BuildContext context) async {
    final dbService = UserTransactionsDBService();
    await dbService.delete(transaction.id!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction deleted successfully')),
      );
    }
    onRefresh();
  }

  // Handle the edit operation (this will open the existing popup)
  void _editTransaction(BuildContext context) {
    // Open the existing ExpenseEntryPopup with the transaction data pre-filled
    onEditClicked();
  }

  @override
  Widget build(BuildContext context) {
    String borrowedStatus = "";
    final bool toSelf = transaction.payerName == transaction.receiverName;

    if (!toSelf && transaction.isBorrowedOrLended == 1) {
      borrowedStatus = transaction.payerName == userName ? "Lend" : "Borrowed";
    }

    return GestureDetector(
      onLongPress: () => _showActionSheet(context),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurpleAccent,
            child: Icon(Icons.currency_rupee, color: Colors.white),
          ),
          title: Text(
            toSelf
                ? "Self"
                : "${transaction.payerName} → ${transaction.receiverName}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.description ?? '-'),
              Text(
                "Group: ${ListOfExpenses.getExpenseName(transaction.expenseGroupId)}",
              ),
              Text("Date: ${transaction.expenseDate ?? ''}"),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${transaction.amount?.toStringAsFixed(2) ?? '0.00'}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Visibility(
                visible: borrowedStatus != "",
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: borrowedStatus == "Borrowed"
                        ? Colors.red[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    borrowedStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: borrowedStatus == "Borrowed"
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
