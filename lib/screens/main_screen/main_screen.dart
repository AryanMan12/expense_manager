import 'dart:async';
import 'package:expense_manager/database/db_init_data.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/dashboard_screen/dashboard_screen.dart';
import 'package:expense_manager/screens/profile_screen/profile_screen.dart';
import 'package:expense_manager/screens/transactions_screen/transactions_screen.dart';
import 'package:expense_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

List<GlobalKey<NavigatorState>> screenKeys = [
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;

  List<Widget> screens = [
    TransactionsScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  bool _backButtonPressedOnce = false;
  bool isLoading = true;

  late UserDetailsProvider _userDetailsProvider;

  @override
  void initState() {
    super.initState();
    _userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );
    _loadUserDetails();
    DbInitData.initializeCategoryAndSubCategory();
  }

  Future<void> _loadUserDetails() async {
    await _userDetailsProvider.getUserDetails();

    // Wait for 1 second before setting isLoading false
    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void changeTabEvent(int index) {
    setState(() => selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: mainNavigatorKey,
      home: Consumer<AppDataProvider>(
        builder: (context, appDataProvider, child) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              if (screenKeys[appDataProvider.currentTab].currentState!
                  .canPop()) {
                screenKeys[appDataProvider.currentTab].currentState!.pop();
                return;
              }

              // If the inner navigator can't pop, check the main navigator (navigatorKey)
              if (mainNavigatorKey.currentState!.canPop()) {
                mainNavigatorKey.currentState!.pop();
                return;
              }

              // Double-tap-to-exit logic
              if (_backButtonPressedOnce) {
                // Exit the app
                SystemNavigator.pop();
                return;
              }

              _backButtonPressedOnce = true;
              SnackBar(content: Text('Click back again to exit the app'));

              // Reset the flag after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                _backButtonPressedOnce = false;
              });
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(appName, style: TextStyle(fontFamily: "Ariel")),
              ),
              body: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        _buildOffstageNavigator(0, appDataProvider.currentTab),
                        _buildOffstageNavigator(1, appDataProvider.currentTab),
                        _buildOffstageNavigator(2, appDataProvider.currentTab),
                      ],
                    ),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet),
                    label: "Main",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: "Dashboard",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
                onTap: (value) {
                  appDataProvider.changeTab(value);
                  changeTabEvent(value);
                },
                currentIndex: appDataProvider.currentTab,
                selectedItemColor: Colors.deepPurpleAccent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffstageNavigator(int pageIndex, int selectedIndex) {
    return Offstage(
      offstage: pageIndex != selectedIndex,
      child: Navigator(
        key: screenKeys[pageIndex],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => screens[pageIndex]);
        },
      ),
    );
  }
}
