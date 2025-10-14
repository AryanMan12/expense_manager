import 'package:expense_manager/screens/list_of_users/widgets/single_user_list_tile.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';

class ListOfUsersScreen extends StatelessWidget {
  const ListOfUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader(
            screenName: "Users",
            hasBack: true,
            onBackClick: (callback) {
              if (!callback) return;
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return SingleUserListTile();
              },
            ),
          ),
        ],
      ),
    );
  }
}
