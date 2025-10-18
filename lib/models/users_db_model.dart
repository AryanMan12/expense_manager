import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "users";
const String nameField = "name";
const String totalField = "total";
const String savingsField = "savings";
const String investedField = "invested";
const String dailyLimitField = "daily_limit";
const String moneyLeftFromDailyField = "money_left_from_daily";
const String moneyBorrowedField = "money_borrowed";
const String moneyLendField = "money_lend";
const String isActiveField = "is_active";

// List of columns in the users table
const List<String> usersColumns = [
  idField,
  nameField,
  totalField,
  savingsField,
  investedField,
  dailyLimitField,
  moneyLeftFromDailyField,
  moneyBorrowedField,
  moneyLendField,
  createdDateField,
  modifiedDateField,
  isActiveField,
];

// Model
class UserModel {
  final int? id;
  final String? name;
  final double? total;
  final double? savings;
  final double? invested;
  final double? dailyLimit;
  final double? moneyLeftFromDaily;
  final double? moneyBorrowed;
  final double? moneyLend;
  final String? createdDate;
  final String? modifiedDate;
  final bool? isActive;

  UserModel({
    this.id,
    this.name,
    this.total,
    this.savings,
    this.invested,
    this.dailyLimit,
    this.moneyLeftFromDaily,
    this.moneyBorrowed,
    this.moneyLend,
    this.createdDate,
    this.modifiedDate,
    this.isActive,
  });

  // Convert JSON to Model
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json[idField],
    name: json[nameField],
    total: json[totalField],
    savings: json[savingsField],
    invested: json[investedField],
    dailyLimit: json[dailyLimitField],
    moneyLeftFromDaily: json[moneyLeftFromDailyField],
    moneyBorrowed: json[moneyBorrowedField],
    moneyLend: json[moneyLendField],
    createdDate: json[createdDateField],
    modifiedDate: json[modifiedDateField],
    isActive: json[isActiveField] == 1,
  );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    nameField: name,
    totalField: total,
    savingsField: savings,
    investedField: invested,
    dailyLimitField: dailyLimit,
    moneyLeftFromDailyField: moneyLeftFromDaily,
    moneyBorrowedField: moneyBorrowed,
    moneyLendField: moneyLend,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
    isActiveField: isActive == true ? 1 : 0,
  };

  UserModel copyWith({
    int? id,
    String? name,
    double? total,
    double? savings,
    double? invested,
    double? dailyLimit,
    double? moneyLeftFromDaily,
    double? moneyBorrowed,
    double? moneyLend,
    String? createdDate,
    String? modifiedDate,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      total: total ?? this.total,
      savings: savings ?? this.savings,
      invested: invested ?? this.invested,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      moneyLeftFromDaily: moneyLeftFromDaily ?? this.moneyLeftFromDaily,
      moneyBorrowed: moneyBorrowed ?? this.moneyBorrowed,
      moneyLend: moneyLend ?? this.moneyLend,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
