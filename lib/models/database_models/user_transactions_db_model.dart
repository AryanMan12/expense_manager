import 'package:expense_manager/database/database_config.dart';

// DB Constants
const String tableName = "user_transactions";
const String payerNameField =
    "payer_name"; // Foreign Key to User (or related entity)
const String receiverNameField =
    "receiver_name"; // Foreign Key to User (or related entity)
const String amountField = "amount";
const String descriptionField = "description";
const String expenseGroupIdField =
    "expense_group_id"; // Foreign Key to Expense Group
const String eventIdField = "event_id"; // Foreign Key to Event
const String splitTransactionIdField =
    "split_transaction_id"; // ID of related split transaction
const String isBorrowedOrLendedField = "is_borrowed_or_lended"; // 1 or 2
const String expenseDateField = "expense_date";

// List of columns in the user_transactions table
const List<String> userTransactionsColumns = [
  idField,
  payerNameField,
  receiverNameField,
  amountField,
  descriptionField,
  expenseGroupIdField,
  eventIdField,
  splitTransactionIdField,
  isBorrowedOrLendedField,
  expenseDateField,
  createdDateField,
  modifiedDateField,
];

// Model
class UserTransactionModel {
  final int? id;
  final String? payerName;
  final String? receiverName;
  final double? amount;
  final String? description;
  final int? expenseGroupId; // Foreign Key to Expense Group
  final int? eventId; // Foreign Key to Event
  final int? splitTransactionId; // ID of related split transaction
  final int? isBorrowedOrLended; // 1 or 2, indicating borrowed or lent
  final String? expenseDate;
  final String? createdDate;
  final String? modifiedDate;

  UserTransactionModel({
    this.id,
    this.payerName,
    this.receiverName,
    this.amount,
    this.description,
    this.expenseGroupId,
    this.eventId,
    this.splitTransactionId,
    this.isBorrowedOrLended,
    this.expenseDate,
    this.createdDate,
    this.modifiedDate,
  });

  // Convert JSON to Model
  factory UserTransactionModel.fromJson(Map<String, dynamic> json) =>
      UserTransactionModel(
        id: json[idField],
        payerName: json[payerNameField],
        receiverName: json[receiverNameField],
        amount: json[amountField],
        description: json[descriptionField],
        expenseGroupId: json[expenseGroupIdField],
        eventId: json[eventIdField],
        splitTransactionId: json[splitTransactionIdField],
        isBorrowedOrLended: json[isBorrowedOrLendedField],
        expenseDate: json[expenseDateField],
        createdDate: json[createdDateField],
        modifiedDate: json[modifiedDateField],
      );

  // Convert Model to JSON
  Map<String, dynamic> toJson() => {
    idField: id,
    payerNameField: payerName,
    receiverNameField: receiverName,
    amountField: amount,
    descriptionField: description,
    expenseGroupIdField: expenseGroupId,
    eventIdField: eventId,
    splitTransactionIdField: splitTransactionId,
    isBorrowedOrLendedField: isBorrowedOrLended,
    expenseDateField: expenseDate,
    createdDateField: createdDate,
    modifiedDateField: modifiedDate,
  };
}
