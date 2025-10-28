import 'package:flutter/material.dart';

class CustomDropdownBox<T> extends StatelessWidget {
  final String hintText;
  final List<T> items;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final TextStyle? textStyle;
  final bool showBorder;
  final TextAlign? textAlign;
  final bool? showFloatingHint;

  const CustomDropdownBox({
    super.key,
    required this.hintText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.textStyle,
    this.showBorder = true,
    this.textAlign,
    this.showFloatingHint,
  });

  @override
  Widget build(BuildContext context) {
    final border = showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          )
        : InputBorder.none;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButtonFormField<T>(
        initialValue: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
              style: textStyle,
              textAlign: textAlign ?? TextAlign.start,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: showFloatingHint == true
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
