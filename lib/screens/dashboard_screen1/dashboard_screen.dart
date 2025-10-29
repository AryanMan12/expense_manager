import 'package:expense_manager/providers/dashboard_provider.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/providers/user_details_provider.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/category_pie_chart.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/dashboard_card.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/monthly_transaction_calendar.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/payer_receiver_card.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/spending_trend_chart.dart';
import 'package:expense_manager/screens/dashboard_screen1/widgets/top_subcategories_list.dart';
import 'package:expense_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardDataProvider provider;
  late ExpenseCategoryProvider _categoryProvider;
  late UserDetailsProvider _userDetailsProvider;
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    provider = DashboardDataProvider();

    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(Duration(days: 1)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _categoryProvider = Provider.of<ExpenseCategoryProvider>(
        context,
        listen: false,
      );
      _userDetailsProvider = Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      );

      await _categoryProvider.fetchCategories();

      for (final cat in _categoryProvider.categories) {
        await _categoryProvider.fetchSubCategories(cat.id!);
      }

      if (_categoryProvider.categories.isNotEmpty && mounted) {
        await provider.loadDashboardData(
          context: context,
          startDate: selectedRange!.start,
          endDate: selectedRange!.end,
          currentUserName: _userDetailsProvider.user?.name ?? "Username",
        );
      } else {
        debugPrint("No categories found when loading dashboard");
      }

      setState(() {});
    });
  }

  Future<void> _loadDashboardData() async {
    await provider.loadDashboardData(
      context: context,
      startDate: selectedRange!.start,
      endDate: selectedRange!.end,
      currentUserName: _userDetailsProvider.user?.name ?? "Username",
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
      initialDateRange: selectedRange,
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      await _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        body: Consumer<UserDetailsProvider>(
          builder: (context, userDetailsProvider, child) {
            return userDetailsProvider.user?.name == null
                ? Center(child: Text("Waiting For Useranme"))
                : Consumer<DashboardDataProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.transactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insights_outlined,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No transactions found in this range",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              InkWell(
                                onTap: _loadDashboardData,
                                child: Text("Refresh"),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadDashboardData,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          children: [
                            _buildHeader(theme),
                            const SizedBox(height: 12),
                            _animatedSection(
                              _buildTrendChart(),
                              key: const ValueKey('trend_chart'),
                            ),
                            _animatedSection(
                              _buildCategoryPieChart(),
                              key: const ValueKey('category_pie_chart'),
                            ),
                            _animatedSection(
                              _buildTopSubcategories(),
                              key: const ValueKey('subcategory_pie_chart'),
                            ),
                            _animatedSection(
                              _buildPayerReceiverSection(),
                              key: const ValueKey('payer_receiver_chart'),
                            ),
                            _animatedSection(
                              _buildBorrowedLentOverview(),
                              key: const ValueKey('borrowed_lent_sum_chart'),
                            ),
                            _animatedSection(
                              _buildHeatMap(),
                              key: const ValueKey('heat_map_chart'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final start = selectedRange!.start;
    final end = selectedRange!.end;
    final dateText =
        "${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        title: Text(
          "Summary Period",
          style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        subtitle: Text(
          dateText,
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.edit_calendar,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          onPressed: _pickDateRange,
        ),
      ),
    );
  }

  Widget _animatedSection(Widget child, {Key? key}) {
    return AnimatedSwitcher(
      key: key,
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      child: child,
    );
  }

  Widget _buildTrendChart() => TweenAnimationBuilder(
    duration: const Duration(milliseconds: 350),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    ),
    child: DashboardCard(
      title: "Spending Trend (Last 30 Days)",
      icon: Icons.show_chart_rounded,
      child: SpendingTrendChart(data: provider.dailyTotals),
    ),
  );

  Widget _buildCategoryPieChart() => TweenAnimationBuilder(
    duration: const Duration(milliseconds: 350),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    ),
    child: DashboardCard(
      title: "Top Spending Categories",
      icon: Icons.pie_chart_rounded,
      child: GestureDetector(
        onTap: () => _showDetailsDialog(
          "Top Spending Categories",
          provider.topCategories,
        ),
        child: Column(
          children: [
            CategoryPieChart(data: provider.topCategories),
            const SizedBox(height: 12),
            _buildChartLegend(provider.topCategories),
          ],
        ),
      ),
    ),
  );

  Widget _buildTopSubcategories() => TweenAnimationBuilder(
    duration: const Duration(milliseconds: 350),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    ),
    child: DashboardCard(
      title: "Top Subcategories",
      icon: Icons.category_rounded,
      child: GestureDetector(
        onTap: () =>
            _showDetailsDialog("Top Subcategories", provider.topSubCategories),
        child: TopSubcategoriesList(data: provider.topSubCategories),
      ),
    ),
  );

  Widget _buildPayerReceiverSection() => TweenAnimationBuilder(
    duration: const Duration(milliseconds: 350),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    ),
    child: DashboardCard(
      title: "Payer / Receiver Analysis",
      icon: Icons.compare_arrows_rounded,
      child: GestureDetector(
        onTap: () => _showNestedMapDialog(
          "Payer / Receiver Details",
          provider.payerReceiverData,
        ),
        child: Column(
          children: [
            PayerReceiverAnalysisCard(data: provider.payerReceiverData),
            const SizedBox(height: 12),
            Text(
              "Tap for full payer → receiver matrix",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeatMap() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 350),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: DashboardCard(
        title: "Monthly Transaction Calendar",
        icon: Icons.calendar_month_rounded,
        child: MonthlyTransactionCalendar(dailyTotals: provider.dailyTotals),
      ),
    );
  }

  Widget _buildBorrowedLentOverview() {
    final net = provider.totalLent - provider.totalBorrowed;
    final netColor = net >= 0 ? Colors.green : Colors.red;
    final data = {
      "Borrowed": provider.totalBorrowed,
      "Lent": provider.totalLent,
    };

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 350),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: DashboardCard(
        title: "Borrowed vs Lent Overview",
        icon: Icons.account_balance_wallet_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart
            GestureDetector(
              onTap: () => _showDetailsDialog("Borrowed vs Lent", data),
              child: Column(
                children: [
                  CategoryPieChart(data: data),
                  const SizedBox(height: 12),
                  _buildChartLegend(data),
                ],
              ),
            ),
            const Divider(height: 24),
            // Summary
            _summaryRow("Total Borrowed", provider.totalBorrowed, Colors.red),
            const SizedBox(height: 6),
            _summaryRow("Total Lent", provider.totalLent, Colors.green),
            const SizedBox(height: 6),
            _summaryRow("Net Balance", net, netColor, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(Map<String, double> data) {
    final entries = data.entries.take(6).toList();
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < entries.length; i++)
          _legendItem(entries[i].key, chartColors[i % chartColors.length]),
      ],
    );
  }

  Widget _legendItem(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );

  void _showDetailsDialog(String title, Map<String, double> data) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: data.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = data.entries.elementAt(index);
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text("₹${entry.value.toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNestedMapDialog(
    String title,
    Map<String, Map<String, double>> data,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...data.entries.map((payerEntry) {
              return ExpansionTile(
                title: Text(
                  payerEntry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                children: payerEntry.value.entries
                    .map(
                      (receiver) => ListTile(
                        dense: true,
                        title: Text(receiver.key),
                        trailing: Text("₹${receiver.value.toStringAsFixed(2)}"),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
