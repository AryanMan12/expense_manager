import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';

class CustomTextBox extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPasswordField;
  final IconData icon;
  final TextInputType inputType;
  final Color? iconColor;
  final StringCallback? onChange;

  const CustomTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
    this.icon = Icons.text_fields,
    this.inputType = TextInputType.text,
    this.iconColor,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPasswordField,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        keyboardType: inputType,
        onChanged: onChange,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
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
