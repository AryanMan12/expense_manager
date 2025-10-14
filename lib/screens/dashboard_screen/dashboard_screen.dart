import 'package:expense_manager/models/database_models/user_transactions_db_model.dart';
import 'package:expense_manager/screens/dashboard_screen/widgets/dashboard_charts_widget.dart';
import 'package:expense_manager/screens/dashboard_screen/widgets/dashboard_helper_summary_widgets.dart';
import 'package:expense_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/database/user_transactions_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardScreen> {
  DateTimeRange currentRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now().add(Duration(days: 1)),
  );

  double totalSpent = 0;
  double totalBorrowed = 0;
  double totalLent = 0;
  Map<int, double> expensesByCategory = {};
  List<UserTransactionModel> timeseriesData = [];
  List<Map<String, dynamic>> categoryBreakdown = [];
  List<Map<String, dynamic>> timeseries = [];

  String userName = "Aryan";

  @override
  void initState() {
    super.initState();
    initialDataFromDB();
  }

  // Fetching data from DB
  Future<void> initialDataFromDB() async {
    final db = UserTransactionsDBService();

    totalSpent = await db.getTotalAmountSpent(
      currentRange.start,
      currentRange.end,
    );

    totalBorrowed =
        (await db.getTotalBorrowedLentAmounts(
          currentRange.start,
          currentRange.end,
          userName,
        ))['totalBorrowed'] ??
        0;

    totalLent =
        (await db.getTotalBorrowedLentAmounts(
          currentRange.start,
          currentRange.end,
          userName,
        ))['totalLent'] ??
        0;

    expensesByCategory = await db.getExpensesByGroup(
      currentRange.start,
      currentRange.end,
    );

    timeseriesData = await db.getTransactionsInRange(
      currentRange.start,
      currentRange.end,
    );

    categoryBreakdown = expensesByCategory.entries
        .map(
          (entry) => {
            'category': ListOfExpenses.getExpenseName(entry.key),
            'total': entry.value,
          },
        )
        .toList();

    timeseries = timeseriesData.map((transaction) {
      return {
        'day_ms': DateTime.parse(
          transaction.expenseDate ?? "-",
        ).millisecondsSinceEpoch,
        'total': transaction.amount,
      };
    }).toList();

    setState(() {});
  }

  // Date Range Picker
  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: currentRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (pickedRange != null) {
      setState(() {
        currentRange = pickedRange;
      });
      initialDataFromDB();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => pickDateRange(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await initialDataFromDB();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Section
              Card(
                child: ListTile(
                  title: Text(
                    'Showing Data from: ${currentRange.start.toLocal()} to ${currentRange.end.toLocal()}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 12),

              // Summary Cards
              Row(
                children: [
                  buildSummaryCard('Total Spent', totalSpent),
                  buildSummaryCard('Total Borrowed', totalBorrowed),
                  buildSummaryCard('Total Lent', totalLent),
                ],
              ),
              SizedBox(height: 24),

              // Category Breakdown (Pie Chart)
              Text(
                'Expenses by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: DashboardChartsWidget(
                  context,
                ).buildPieChart(categoryBreakdown, timeseriesData),
              ),

              SizedBox(height: 24),

              // Expense Trend (Line Chart)
              Text(
                'Expense Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: DashboardChartsWidget(
                  context,
                ).buildLineChart(timeseries, timeseriesData),
              ),

              SizedBox(height: 24),

              // Insights Section
              Text('Insights', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              buildInsights(expensesByCategory),
            ],
          ),
        ),
      ),
    );
  }
}
