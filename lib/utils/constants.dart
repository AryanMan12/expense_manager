import 'package:flutter/material.dart';

const String appName = "Expense Tracker";

class ListOfExpenses {
  static const List<String> listOfExpenses = [
    "Food",
    "Travel",
    "Shopping",
    "Luxuary",
    "Household",
    "Savings",
    "Investment",
    "EMI/Loans/Bill",
    "Personal",
    "Miscellaneous",
  ];

  static int getExpenseId(String? expenseItem) {
    if (listOfExpenses.contains(expenseItem)) {
      return listOfExpenses.indexOf(expenseItem!) + 1;
    } else {
      return listOfExpenses.length;
    }
  }

  static String getExpenseName(int? id) {
    if (id != null && id > 0 && id <= listOfExpenses.length) {
      return listOfExpenses[id - 1];
    } else {
      return listOfExpenses.last;
    }
  }

  static Widget getExpenseIcon(String? expenseItem, {double size = 28}) {
    switch (expenseItem) {
      case "Food":
        return Text('🍔', style: TextStyle(fontSize: size));
      case "Travel":
        return Text('✈️', style: TextStyle(fontSize: size));
      case "Shopping":
        return Text('🛍️', style: TextStyle(fontSize: size));
      case "Luxuary":
        return Text('💎', style: TextStyle(fontSize: size));
      case "Household":
        return Text('🏠', style: TextStyle(fontSize: size));
      case "Savings":
        return Text('💰', style: TextStyle(fontSize: size));
      case "Investment":
        return Text('📈', style: TextStyle(fontSize: size));
      case "EMI/Loans/Bill":
        return Text('🧾', style: TextStyle(fontSize: size));
      case "Personal":
        return Text('🙋‍♂️', style: TextStyle(fontSize: size));
      default:
        return Text('❓', style: TextStyle(fontSize: size));
    }
  }
}
