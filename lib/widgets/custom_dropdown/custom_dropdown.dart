import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final double borderRadius;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.icon = Icons.arrow_drop_down,
    this.borderRadius = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ), // Custom border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        ),
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          isExpanded: true,
          underline: SizedBox(),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
