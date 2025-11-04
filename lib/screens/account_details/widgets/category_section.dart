import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:flutter/material.dart';

class CategoryTransactionsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final double total;
  final List<UserTransactionModel> transactions;
  final VoidCallback onAddPressed;
  final Function(UserTransactionModel) onEdit;
  final Function(UserTransactionModel) onDelete;
  final Color? accent;

  const CategoryTransactionsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.total,
    required this.transactions,
    required this.onAddPressed,
    required this.onEdit,
    required this.onDelete,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTxns = [...transactions]
      ..sort(
        (a, b) => DateTime.parse(
          b.expenseDate ?? '',
        ).compareTo(DateTime.parse(a.expenseDate ?? '')),
      );

    return ExpansionTile(
      leading: Icon(icon, color: accent ?? Colors.deepPurpleAccent),
      title: Text(
        "$title  •  ₹${total.toStringAsFixed(2)}",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: accent ?? Colors.deepPurpleAccent,
        ),
      ),
      children: [
        if (transactions.isEmpty)
          _buildAddButton(context, "Add $title Entry", onAddPressed)
        else
          Column(
            children: [
              ..._buildTransactionList(context, sortedTxns),
              const SizedBox(height: 8),
              _buildAddButton(context, "Add More", onAddPressed),
            ],
          ),
      ],
    );
  }

  List<Widget> _buildTransactionList(
    BuildContext context,
    List<UserTransactionModel> txns,
  ) {
    return txns.map((t) {
      final amount = t.amount ?? 0;
      return ListTile(
        dense: true,
        title: Text(
          t.description?.isNotEmpty == true
              ? t.description!
              : "(No description)",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "${t.payerName} → ${t.receiverName}\n${t.expenseDate?.split('T').first ?? ''}",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          "₹${amount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        onLongPress: () => _showEditDeleteDialog(context, t),
      );
    }).toList();
  }

  Widget _buildAddButton(
    BuildContext context,
    String label,
    VoidCallback onAddPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(label),
        onPressed: onAddPressed,
      ),
    );
  }

  void _showEditDeleteDialog(BuildContext context, UserTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blueAccent),
                title: const Text("Edit Transaction"),
                onTap: () {
                  Navigator.pop(context);
                  onEdit(txn);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Delete Transaction"),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(txn);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
