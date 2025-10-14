class AddTransactionModel {
  final int? id;
  final int? from;
  final int? to;
  final double? amount;
  final String? description;
  final int? expenseGroupId;
  final int? eventId;
  final int? splitTransactionId;
  final int? isBorrowedOrLended;
  final String? expenseDate;
  final String? createdDate;
  final String? modifiedDate;

  AddTransactionModel({
    this.id,
    this.from,
    this.to,
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
}
