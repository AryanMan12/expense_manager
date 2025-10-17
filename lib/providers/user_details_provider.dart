import 'package:expense_manager/database/users_database.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/database_models/users_db_model.dart';

class UserDetailsProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  Future<void> getUserDetails() async {
    UserModel? localUser = await UserDBService().getById(1);
    _user = localUser;
    notifyListeners();
  }

  Future<void> updateUserDetails(UserModel userModel) async {
    _user = userModel;
    await UserDBService().update(userModel);
    notifyListeners();
  }
}
