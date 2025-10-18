import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "periodic_expense";
const String nameField = "name";
const String tagsField = "tags";
const String amountField = "amount";
const String descriptionField = "description";
const String onUserIdField = "on_user_id";
const String expenseGroupField = "expense_group";
const String periodicDateField = "periodic_date";
const String repeatsEveryField = "repeats_every";
const String isActiveField = "is_active";

// List of columns in the periodic_expense table
const List<String> periodicExpenseColumns = [
  idField,
  nameField,
  tagsField,
  amountField,
  descriptionField,
  onUserIdField,
  expenseGroupField,
  periodicDateField,
  repeatsEveryField,
  createdDateField,
  modifiedDateField,
  isActiveField,
];

// Model
class PeriodicExpenseModel {
  final int? id;
  final String? name;
  final String? tags;
  final double? amount;
  final String? description;
  final int? onUserId; // Foreign Key to User
  final int? expenseGroup; // Foreign Key to Expense Group
  final String? periodicDate;
  final String? repeatsEvery;
  final String? createdDate;
  final String? modifiedDate;
  final bool? isActive;

  PeriodicExpenseModel({
    this.id,
    this.name,
    this.tags,
    this.amount,
    this.description,
    this.onUserId,
    this.expenseGroup,
    this.periodicDate,
    this.repeatsEvery,
    this.createdDate,
    this.modifiedDate,
    this.isActive,
  });

  // Convert JSON to Model
  factory PeriodicExpenseModel.fromJson(Map<String, dynamic> json) =>
      PeriodicExpenseModel(
        id: json[idField],
        name: json[nameField],
        tags: json[tagsField],
        amount: json[amountField],
        description: json[descriptionField],
        onUserId: json[onUserIdField],
        expenseGroup: json[expenseGroupField],
        periodicDate: json[periodicDateField],
        repeatsEvery: json[repeatsEveryField],
        createdDate: json[createdDateField],
        modifiedDate: json[modifiedDateField],
        isActive: json[isActiveField],
      );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    nameField: name,
    tagsField: tags,
    amountField: amount,
    descriptionField: description,
    onUserIdField: onUserId,
    expenseGroupField: expenseGroup,
    periodicDateField: periodicDate,
    repeatsEveryField: repeatsEvery,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
    isActiveField: isActive,
  };
}
