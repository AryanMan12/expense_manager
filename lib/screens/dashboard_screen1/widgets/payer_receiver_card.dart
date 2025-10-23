import 'package:flutter/material.dart';

class PayerReceiverAnalysisCard extends StatelessWidget {
  final Map<String, Map<String, double>> data;

  const PayerReceiverAnalysisCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No payer/receiver data available"));
    }

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => (b.value['net'] ?? 0).compareTo(a.value['net'] ?? 0));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final name = sortedEntries[index].key;
        final values = sortedEntries[index].value;
        final paid = values['paid'] ?? 0;
        final received = values['received'] ?? 0;
        final net = values['net'] ?? 0;

        final netColor = net >= 0 ? Colors.green : Colors.red;
        final netText = net >= 0
            ? "+₹${net.toStringAsFixed(0)}"
            : "-₹${net.abs().toStringAsFixed(0)}";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Paid: ₹${paid.toStringAsFixed(0)} | Received: ₹${received.toStringAsFixed(0)}",
            ),
            trailing: Text(
              netText,
              style: TextStyle(color: netColor, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
