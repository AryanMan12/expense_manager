import 'package:expense_manager/providers/dashboard_provider.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/category_pie_chart.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/dashboard_card.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/payer_receiver_card.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/spending_trend_chart.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/top_subcategories_list.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardDataProvider provider;

  @override
  void initState() {
    super.initState();
    provider = DashboardDataProvider();
    provider.loadDashboardData(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildTrendChart(),
              _buildCategoryPieChart(),
              _buildTopSubcategories(),
              _buildPayerBreakdownCard(),
              _buildPayerReceiverSection(),
              _buildHeatMap(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrendChart() {
    return DashboardCard(
      title: "Spending Trend (Last 30 Days)",
      child: SpendingTrendChart(data: provider.dailyTotals),
    );
  }

  Widget _buildCategoryPieChart() {
    return DashboardCard(
      title: "Top Spending Categories",
      child: CategoryPieChart(data: provider.topCategories),
    );
  }

  Widget _buildTopSubcategories() {
    return DashboardCard(
      title: "Top Subcategories",
      child: TopSubcategoriesList(data: provider.topSubCategories),
    );
  }

  Widget _buildPayerBreakdownCard() {
    return DashboardCard(
      title: "Top Payers",
      child: Column(
        children: provider.payerBreakdown.entries
            .map(
              (e) => ListTile(
                title: Text(e.key),
                trailing: Text(e.value.toStringAsFixed(2)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPayerReceiverSection() {
    return DashboardCard(
      title: "Payer / Receiver Analysis",
      child: PayerReceiverAnalysisCard(data: provider.payerReceiverData),
    );
  }

  Widget _buildHeatMap() {
    return DashboardCard(
      title: "Heatmap of your Transaction",
      child: HeatMap(
        datasets: provider.dailyTotals.map(
          (date, amount) => MapEntry(date, amount.toInt()),
        ),
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200],
        textColor: Colors.black,
        showColorTip: true,
        size: 30,
        colorsets: {
          1: Colors.green[100]!,
          5: Colors.green[300]!,
          10: Colors.green[500]!,
          20: Colors.green[700]!,
        },
        startDate: provider.dailyTotals.keys.isNotEmpty
            ? provider.dailyTotals.keys.reduce((a, b) => a.isBefore(b) ? a : b)
            : DateTime.now(),
        endDate: provider.dailyTotals.keys.isNotEmpty
            ? provider.dailyTotals.keys.reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime.now(),
      ),
    );
  }
}
