import 'package:expense_manager/models/users_db_model.dart';
import 'package:flutter/material.dart';

class SingleUserListTile extends StatelessWidget {
  final UserModel user;

  const SingleUserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final balance = (user.moneyLend ?? 0) - (user.moneyBorrowed ?? 0);
    final color = balance >= 0 ? Colors.green : Colors.red;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.name ?? "Unnamed User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Borrowed: ₹${user.moneyBorrowed?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    Text(
                      "Lent: ₹${user.moneyLend?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      "Balance: ₹${balance.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 0.5,
            height: 1,
            color: Colors.deepPurpleAccent,
          ),
        ],
      ),
    );
  }
}
