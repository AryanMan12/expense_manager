import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "expense_sub_group";
const String nameField = "name";
const String iconField = "icon";
const String tagsField = "tags";
const String categoryIdField = "categoryId";

// List of columns in the expense_group table
const List<String> expenseSubGroupColumns = [
  idField,
  nameField,
  iconField,
  tagsField,
  categoryIdField,
  createdDateField,
  modifiedDateField,
];

// Sub Category Model
class ExpenseSubCategoryModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? icon;
  final String? tags;
  final String? createdDate;
  final String? modifiedDate;

  ExpenseSubCategoryModel({
    this.id,
    this.categoryId,
    this.name,
    this.icon,
    this.tags,
    this.createdDate,
    this.modifiedDate,
  });

  factory ExpenseSubCategoryModel.fromJson(Map<String, dynamic> json) =>
      ExpenseSubCategoryModel(
        id: json[idField],
        categoryId: json[categoryIdField],
        name: json[nameField],
        icon: json[iconField],
        tags: json[tagsField],
        createdDate: json[createdDateField],
        modifiedDate: json[modifiedDateField],
      );

  Map<String, dynamic> toJson() => {
    idField: id,
    categoryIdField: categoryId,
    nameField: name,
    iconField: icon,
    tagsField: tags,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
  };
}
