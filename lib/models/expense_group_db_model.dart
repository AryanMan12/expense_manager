import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "expense_group"; // Table name is now expense_group
const String nameField = "name";
const String tagsField = "tags";

// List of columns in the expense_group table
const List<String> expenseGroupColumns = [
  idField,
  nameField,
  tagsField,
  createdDateField,
  modifiedDateField,
];

// Model
class ExpenseGroupModel {
  final int? id;
  final String? name;
  final String? tags;
  final String? createdDate;
  final String? modifiedDate;

  ExpenseGroupModel({
    this.id,
    this.name,
    this.tags,
    this.createdDate,
    this.modifiedDate,
  });

  // Convert JSON to Model
  factory ExpenseGroupModel.fromJson(Map<String, dynamic> json) =>
      ExpenseGroupModel(
        id: json[idField],
        name: json[nameField],
        tags: json[tagsField],
        createdDate: json[createdDateField],
        modifiedDate: json[modifiedDateField],
      );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    nameField: name,
    tagsField: tags,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
  };
}
