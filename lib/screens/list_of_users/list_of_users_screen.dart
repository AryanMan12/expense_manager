import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/list_of_users/user_details_screen.dart';
import 'package:expense_manager/screens/list_of_users/widgets/add_edit_user_bottom_sheet.dart';
import 'package:expense_manager/screens/list_of_users/widgets/single_user_list_tile.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfUsersScreen extends StatelessWidget {
  const ListOfUsersScreen({super.key});

  void _openAddEditSheet(BuildContext context, {user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditUserBottomSheet(
        user: user,
        onSaved: () => context.read<UserDetailsProvider>().fetchUsers(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDetailsProvider()..fetchUsers(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurpleAccent,
          child: const Icon(Icons.add),
          onPressed: () => _openAddEditSheet(context),
        ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Consumer<UserDetailsProvider>(
                builder: (context, provider, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search user...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: provider.searchUsers,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.sort, color: Colors.deepPurple),
                        onPressed: provider.sortByBalanceDesc,
                        tooltip: 'Sort by Balance (Desc)',
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<UserDetailsProvider>(
                builder: (context, provider, _) {
                  if (provider.users.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.builder(
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailsScreen(user: user),
                            ),
                          );
                        },
                        onLongPress: () {
                          _openAddEditSheet(context, user: user);
                        },
                        child: SingleUserListTile(user: user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
