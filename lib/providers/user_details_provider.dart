import 'package:expense_manager/database/users_database.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/users_db_model.dart';

class UserDetailsProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  Future<void> getUserDetails() async {
    UserModel? localUser = await UserDBService().getById(1);
    _user = localUser;
    notifyListeners();
  }

  Future<void> updateUserDetails(UserModel userModel) async {
    final db = UserDBService();

    // Check if a user already exists
    final existingUser = await db.getById(userModel.id ?? 1);

    if (existingUser == null) {
      // First time user — insert
      await db.insert(userModel);
    } else {
      // Existing user — update
      await db.update(userModel);
    }

    _user = userModel;
    notifyListeners();
  }

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  List<UserModel> get users => _filteredUsers;

  Future<void> fetchUsers() async {
    final db = UserDBService();
    _users = await db.getAll();
    _filteredUsers = _users;
    notifyListeners();
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = _users;
    } else {
      _filteredUsers = _users
          .where(
            (user) =>
                user.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
          )
          .toList();
    }
    notifyListeners();
  }

  void sortByBalanceDesc() {
    _filteredUsers.sort(
      (a, b) => ((b.moneyLend ?? 0) - (b.moneyBorrowed ?? 0)).compareTo(
        (a.moneyLend ?? 0) - (a.moneyBorrowed ?? 0),
      ),
    );
    notifyListeners();
  }
}
