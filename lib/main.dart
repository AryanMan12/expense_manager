import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppDataProvider())],
      child: const MainScreen(),
    ),
  );
}
