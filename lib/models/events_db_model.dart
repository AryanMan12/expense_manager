import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "events";
const String nameField = "name";
const String startDateField = "start_date";
const String endDateField = "end_date";

// List of columns in the events table
const List<String> eventsColumns = [
  idField,
  nameField,
  startDateField,
  endDateField,
  createdDateField,
  modifiedDateField,
];

// Model
class EventModel {
  final int? id;
  final String? name;
  final String? startDate;
  final String? endDate;
  final String? createdDate;
  final String? modifiedDate;

  EventModel({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.createdDate,
    this.modifiedDate,
  });

  // Convert JSON to Model
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json[idField],
    name: json[nameField],
    startDate: json[startDateField],
    endDate: json[endDateField],
    createdDate: json[createdDateField],
    modifiedDate: json[modifiedDateField],
  );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    nameField: name,
    startDateField: startDate,
    endDateField: endDate,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
  };
}
