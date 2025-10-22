import 'package:flutter/material.dart';
import 'package:expense_manager/utils/ui_callbacks.dart';

class CustomTextBox extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPasswordField;
  final IconData? icon;
  final TextInputType inputType;
  final Color? iconColor;
  final StringCallback? onChange;
  final bool autoFocus;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final bool showBorder;
  final bool showIcon;
  final String? helperText;
  final bool? hideBorder;

  const CustomTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
    this.icon,
    this.inputType = TextInputType.text,
    this.iconColor,
    this.onChange,
    this.autoFocus = false,
    this.textStyle,
    this.textAlign,
    this.showBorder = true,
    this.showIcon = true,
    this.helperText,
    this.hideBorder,
  });

  @override
  Widget build(BuildContext context) {
    final border = showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          )
        : InputBorder.none;

    final focusedBorder = showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
          )
        : InputBorder.none;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        obscureText: isPasswordField,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        keyboardType: inputType,
        onChanged: onChange,
        textAlign: textAlign ?? TextAlign.start,
        style: textStyle,
        decoration: InputDecoration(
          prefixIcon: showIcon && icon != null
              ? Icon(icon, color: iconColor)
              : null,
          labelText: hintText,
          labelStyle: textStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: hideBorder == true ? null : border,
          focusedBorder: hideBorder == true ? null : focusedBorder,
          enabledBorder: hideBorder == true ? null : border,
          helperText: helperText,
          helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
