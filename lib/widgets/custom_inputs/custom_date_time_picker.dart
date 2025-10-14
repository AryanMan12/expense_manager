import 'package:expense_manager/utils/date_utils.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final StringCallback? onChange;
  final Color? iconColor;

  const CustomDateTimePicker({
    super.key,
    required this.hintText,
    required this.controller,
    this.onChange,
    this.iconColor,
  });

  // Function to select Date and Time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime currentDate = DateTime.now();

    // Show Date Picker first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && context.mounted) {
      // Show Time Picker only if Date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );

      if (pickedTime != null) {
        // Combine Date and Time into a DateTime object
        final DateTime dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format DateTime for display (e.g., dd/MM/yyyy HH:mm)
        final formattedDateTime = DateFormat(uiDateTimeFormat).format(dateTime);

        // Update the controller with the formatted DateTime
        controller.text = formattedDateTime;

        // If there's an onChange callback, send the ISO 8601 format DateTime
        if (onChange != null) {
          onChange!(dateTime.toIso8601String()); // ISO 8601 format
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: controller,
        readOnly: true, // Prevent manual input
        onTap: () => _selectDateTime(context), // Trigger date & time picker
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.date_range, color: iconColor),
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }
}
