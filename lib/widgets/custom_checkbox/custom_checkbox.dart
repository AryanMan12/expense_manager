import 'package:flutter/material.dart';

class CustomCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool?) onChanged;
  final IconData icon;
  final double borderRadius;

  const CustomCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon = Icons.check_box,
    this.borderRadius = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepPurpleAccent, // Color when checked
          checkColor: Colors.white, // Color of the check mark
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
