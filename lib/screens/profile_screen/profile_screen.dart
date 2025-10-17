import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/account_details/account_details_screen.dart';
import 'package:expense_manager/screens/list_of_expense_group/list_of_expense_group_screen.dart';
import 'package:expense_manager/screens/list_of_users/list_of_users_screen.dart';
import 'package:expense_manager/screens/profile_screen/widgets/circular_profile.dart';
import 'package:expense_manager/screens/profile_screen/widgets/profile_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child) {
        return Column(
          children: [
            const SizedBox(height: 10),
            CircularProfile(userName: userDetailsProvider.user!.name!),
            const SizedBox(height: 5),
            Container(
              height: 5,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView(
                children: [
                  ProfileMenuWidget(
                    menuName: "Account Details",
                    icon: Icons.person,
                    screen: AccountDetailsScreen(),
                  ),
                  ProfileMenuWidget(
                    menuName: "List Of Users",
                    icon: Icons.group,
                    screen: ListOfUsersScreen(),
                  ),
                  ProfileMenuWidget(
                    menuName: "Expense Groups",
                    icon: Icons.workspaces_outline,
                    screen: ListOfExpenseGroupScreen(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
