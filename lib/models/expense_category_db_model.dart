import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "expense_group";
const String nameField = "name";
const String iconField = "icon";
const String tagsField = "tags";

// List of columns in the expense_group table
const List<String> expenseGroupColumns = [
  idField,
  nameField,
  iconField,
  tagsField,
  createdDateField,
  modifiedDateField,
];

// Category Model
class ExpenseCategoryModel {
  final int? id;
  final String? name;
  final String? icon;
  final String? tags;
  final String? createdDate;
  final String? modifiedDate;

  ExpenseCategoryModel({
    this.id,
    this.name,
    this.icon,
    this.tags,
    this.createdDate,
    this.modifiedDate,
  });

  // Convert JSON to Model
  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) =>
      ExpenseCategoryModel(
        id: json[idField],
        name: json[nameField],
        icon: json[iconField],
        tags: json[tagsField],
        createdDate: json[createdDateField],
        modifiedDate: json[modifiedDateField],
      );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    nameField: name,
    iconField: icon,
    tagsField: tags,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
  };
}
