import 'package:expense_manager/models/database_models/user_transactions_db_model.dart';
import 'package:expense_manager/screens/dashboard_screen/widgets/view_pie_chart_details.dart';
import 'package:expense_manager/utils/constants.dart';
import 'package:expense_manager/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_manager/database/user_transactions_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardScreen> {
  DateTimeRange currentRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );

  double totalSpent = 0;
  double totalBorrowed = 0;
  double totalLent = 0;
  Map<int, double> expensesByCategory = {};
  List<UserTransactionModel> timeseriesData = [];
  List<Map<String, dynamic>> categoryBreakdown = [];
  List<Map<String, dynamic>> timeseries = [];

  bool _isBottomSheetOpen = false;

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
      lastDate: DateTime.now(),
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
                  _buildSummaryCard('Total Spent', totalSpent),
                  _buildSummaryCard('Total Borrowed', totalBorrowed),
                  _buildSummaryCard('Total Lent', totalLent),
                ],
              ),
              SizedBox(height: 24),

              // Category Breakdown (Pie Chart)
              Text(
                'Expenses by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              SizedBox(height: 220, child: _buildPieChart(categoryBreakdown)),

              SizedBox(height: 24),

              // Expense Trend (Line Chart)
              Text(
                'Expense Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              SizedBox(height: 220, child: _buildLineChart(timeseries)),

              SizedBox(height: 24),

              // Insights Section
              Text('Insights', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              _buildInsights(),
            ],
          ),
        ),
      ),
    );
  }

  // Build Summary Cards for Total Spent, Borrowed, Lent
  Widget _buildSummaryCard(String title, double amount) {
    return Expanded(
      child: Card(
        child: ListTile(
          title: Text('\$${amount.toStringAsFixed(2)}'),
          subtitle: Text(title),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getRecentTransactionsForCategory(
    String categoryName,
  ) {
    final int categoryId = ListOfExpenses.getExpenseId(categoryName);

    // Filter transactions by group ID
    final filteredTransactions = timeseriesData
        .where((tx) => tx.expenseGroupId == categoryId)
        .toList();

    // Sort by date descending (newest first)
    filteredTransactions.sort(
      (a, b) => DateTime.parse(
        b.expenseDate ?? '',
      ).compareTo(DateTime.parse(a.expenseDate ?? '')),
    );

    // Take most recent 5
    final recent = filteredTransactions.take(5).map((tx) {
      final parsedDate = DateTime.tryParse(tx.expenseDate ?? '');
      final dateString = parsedDate != null
          ? "${parsedDate.day.toString().padLeft(2, '0')} ${monthShort(parsedDate.month)}"
          : "";

      return {
        "title": tx.description ?? "No description",
        "amount": tx.amount ?? 0.0,
        "date": dateString,
      };
    }).toList();

    return recent;
  }

  // Build Pie Chart for Category Breakdown
  Widget _buildPieChart(List<Map<String, dynamic>> breakdown) {
    if (breakdown.isEmpty) return Center(child: Text('No data available'));

    final total = breakdown.fold<double>(
      0,
      (s, r) => s + (r['total'] as num).toDouble(),
    );

    final sections = breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final value = (data['total'] as num).toDouble();
      final percent = (value / total) * 100;
      final color = Colors.primaries[index % Colors.primaries.length];

      return PieChartSectionData(
        value: value,
        title: '${data['category']}\n${percent.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.touchedSection == null) {
              return;
            }

            if (_isBottomSheetOpen) return;

            final section = response.touchedSection;
            if (section == null ||
                section.touchedSectionIndex < 0 ||
                section.touchedSectionIndex >= breakdown.length) {
              return;
            }

            final touchedIndex = section.touchedSectionIndex;
            final selectedCategory = breakdown[touchedIndex];
            final recentTransactions = getRecentTransactionsForCategory(
              selectedCategory['category'],
            );

            _isBottomSheetOpen = true;
            showCategoryDetailsBottomSheet(
              context,
              selectedCategory,
              recentTransactions,
              (callback) => _isBottomSheetOpen = false,
            );
          },
        ),
      ),
    );
  }

  // Build Line Chart for Expense Trend
  Widget _buildLineChart(List<Map<String, dynamic>> series) {
    if (series.isEmpty) return Center(child: Text('No data available'));

    final spots = series.map((r) {
      final dayMs = (r['day_ms'] as int).toDouble();
      final total = (r['total'] as num).toDouble();
      return FlSpot(dayMs, total);
    }).toList();

    final minX = spots.first.x;
    final maxX = spots.last.x;

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${dt.day}/${dt.month}',
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.lineBarSpots == null ||
                response.lineBarSpots!.isEmpty) {
              return;
            }
            if (_isBottomSheetOpen) return;

            final touchedSpot = response.lineBarSpots!.first;
            final tappedTimestamp = touchedSpot.x.toInt();
            _isBottomSheetOpen = true;

            final tappedDate = DateTime.fromMillisecondsSinceEpoch(
              tappedTimestamp,
            );

            // Filter transactions for that day (based on expenseDate)
            final sameDayTransactions = timeseriesData.where((tx) {
              if (tx.expenseDate == null) return false;
              final date = DateTime.tryParse(tx.expenseDate!);
              if (date == null) return false;

              return date.year == tappedDate.year &&
                  date.month == tappedDate.month &&
                  date.day == tappedDate.day;
            }).toList();

            final totalSpent = sameDayTransactions.fold<double>(
              0.0,
              (sum, tx) => sum + (tx.amount ?? 0.0),
            );

            final recentTransactions = sameDayTransactions.take(5).map((tx) {
              return {
                'title': tx.description ?? "No description",
                'amount': tx.amount ?? 0.0,
                'date': "${tappedDate.day} ${monthShort(tappedDate.month)}",
              };
            }).toList();

            showCategoryDetailsBottomSheet(
              context,
              {"date": tappedDate, "total": totalSpent},
              recentTransactions,
              (callback) => _isBottomSheetOpen = false,
            );
          },
        ),
      ),
    );
  }

  // Build Insights Section (e.g., Most Expensive Category, Trends)
  Widget _buildInsights() {
    final mostExpensiveCategory = expensesByCategory.entries.isNotEmpty
        ? expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostExpensiveCategory != null) ...[
          Text(
            'Most Expensive Category: ${ListOfExpenses.getExpenseName(mostExpensiveCategory.key)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Total: \$${mostExpensiveCategory.value.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.green),
          ),
        ],
        SizedBox(height: 12),
        Text(
          'Month-over-Month Trend (if applicable)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          'This section could provide insights such as comparing current month spending with the previous month, or give user tips based on spending habits.',
        ),
      ],
    );
  }
}
