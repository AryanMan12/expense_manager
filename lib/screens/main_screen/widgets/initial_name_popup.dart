import 'package:expense_manager/models/database_models/users_db_model.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showNameInputDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => AlertDialog(
      title: Text('Enter your Name'),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            String name = nameController.text;
            if (name.isNotEmpty) {
              UserModel newUser = UserModel(
                id: 1,
                name: name,
                total: 0.0,
                savings: 0.0,
                invested: 0.0,
                dailyLimit: 0.0,
                moneyLeftFromDaily: 0.0,
                moneyBorrowed: 0.0,
                moneyLend: 0.0,
                createdDate: DateTime.now().toString(),
                modifiedDate: DateTime.now().toString(),
                isActive: true,
              );
              Provider.of<UserDetailsProvider>(
                context,
                listen: false,
              ).updateUserDetails(newUser);
              Navigator.of(dialogCtx).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    ),
  );
}
