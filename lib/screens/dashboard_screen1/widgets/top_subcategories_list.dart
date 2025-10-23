import 'package:flutter/material.dart';

class TopSubcategoriesList extends StatelessWidget {
  final Map<String, double> data;

  const TopSubcategoriesList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No subcategory data available"));
    }

    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxAmount = sortedData.first.value;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        final label = sortedData[index].key;
        final amount = sortedData[index].value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text("₹${amount.toStringAsFixed(0)}"),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: amount / maxAmount,
                color: Colors.teal,
                backgroundColor: Colors.teal.shade100,
                minHeight: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
