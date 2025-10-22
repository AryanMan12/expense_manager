import 'package:expense_manager/models/user_transactions_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/screens/dashboard_screen/widgets/show_chart_details_sheet.dart';
import 'package:expense_manager/utils/date_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardChartsWidget {
  late BuildContext context;
  DashboardChartsWidget(this.context);

  bool _isBottomSheetOpen = false;

  List<Map<String, dynamic>> getRecentTransactionsForCategory(
    String categoryName,
    List<UserTransactionModel> timeseriesData,
  ) {
    final int categoryId = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    ).getCategoryIdByName(categoryName)!;

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
  Widget buildPieChart(
    List<Map<String, dynamic>> breakdown,
    List<UserTransactionModel> timeseriesData,
    ExpenseCategoryProvider categoryProvider,
  ) {
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
              timeseriesData,
            );

            _isBottomSheetOpen = true;
            showDetailsBottomSheet(
              context,
              selectedCategory,
              recentTransactions,
              (callback) => _isBottomSheetOpen = false,
              categoryProvider,
            );
          },
        ),
      ),
    );
  }

  // Build Line Chart for Expense Trend
  Widget buildLineChart(
    List<Map<String, dynamic>> series,
    List<UserTransactionModel> timeseriesData,
    ExpenseCategoryProvider categoryProvider,
  ) {
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

            showDetailsBottomSheet(
              context,
              {"date": tappedDate, "total": totalSpent},
              recentTransactions,
              (callback) => _isBottomSheetOpen = false,
              categoryProvider,
            );
          },
        ),
      ),
    );
  }
}
