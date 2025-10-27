import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No category data available"));
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final colorPalette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    final pieSections = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        color: colorPalette[index % colorPalette.length],
        value: value,
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: pieSections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
