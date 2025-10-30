import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingTrendChart extends StatelessWidget {
  final Map<DateTime, double> data;

  const SpendingTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available for this period"));
    }

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.value;
      return FlSpot(index, value);
    }).toList();

    final minY = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    final maxY = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    final dateLabels = sortedEntries.map((e) {
      return DateFormat('dd MMM').format(e.key);
    }).toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < dateLabels.length) {
                    return Text(
                      dateLabels[index],
                      style: const TextStyle(fontSize: 9),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.deepPurpleAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          minY: minY * 0.9,
          maxY: maxY * 1.1,
        ),
      ),
    );
  }
}
