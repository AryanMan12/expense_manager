import 'package:expense_manager/constants/string_constants.dart';
import 'package:expense_manager/providers/app_data_provider.dart';
import 'package:expense_manager/screens/dashboard_screen/dashboard_screen.dart';
import 'package:expense_manager/screens/profile_screen/profile_screen.dart';
import 'package:expense_manager/screens/transactions_screen/transactions_screen.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void changeTabEvent(int index) {
    setState(() => selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appDataProvider, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (screenKeys[appDataProvider.currentTab].currentState == null) {
              return;
            }
            bool canPop = !await screenKeys[appDataProvider.currentTab]
                .currentState!
                .maybePop();
            if (canPop && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(appName, style: TextStyle(fontFamily: "Ariel")),
            ),
            body: Stack(
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
