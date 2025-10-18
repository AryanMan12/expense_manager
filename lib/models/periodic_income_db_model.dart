import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "periodic_income";
const String nameField = "name";
const String tagsField = "tags";
const String amountField = "amount";
const String descriptionField = "description";
const String fromUserIdField = "from_user_id"; // Foreign Key to User
const String periodicDateField = "periodic_date";
const String repeatsEveryField = "repeats_every";
const String isActiveField = "is_active";

// List of columns in the periodic_income table
const List<String> periodicIncomeColumns = [
  idField,
  nameField,
  tagsField,
  amountField,
  descriptionField,
  fromUserIdField,
  periodicDateField,
  repeatsEveryField,
  createdDateField,
  modifiedDateField,
  isActiveField,
];

// Model
class PeriodicIncomeModel {
  final int? id;
  final String? name;
  final String? tags;
  final double? amount;
  final String? description;
  final int? fromUserId; // Foreign Key to User
  final String? periodicDate;
  final String? repeatsEvery;
  final String? createdDate;
  final String? modifiedDate;
  final bool? isActive;

  PeriodicIncomeModel({
    this.id,
    this.name,
    this.tags,
    this.amount,
    this.description,
    this.fromUserId,
    this.periodicDate,
    this.repeatsEvery,
    this.createdDate,
    this.modifiedDate,
    this.isActive,
  });

  // Convert JSON to Model
  factory PeriodicIncomeModel.fromJson(Map<String, dynamic> json) =>
      PeriodicIncomeModel(
        id: json[idField],
        name: json[nameField],
        tags: json[tagsField],
        amount: json[amountField],
        description: json[descriptionField],
        fromUserId: json[fromUserIdField],
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
    fromUserIdField: fromUserId,
    periodicDateField: periodicDate,
    repeatsEveryField: repeatsEvery,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
    isActiveField: isActive,
  };
}
