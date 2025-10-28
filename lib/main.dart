import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ChangeNotifierProvider(create: (_) => UserDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseCategoryProvider()),
      ],
      child: const ExpenseManagerApp(),
    ),
  );
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      navigatorKey: mainNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
