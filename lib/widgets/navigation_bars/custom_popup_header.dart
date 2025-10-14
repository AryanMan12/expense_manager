import 'package:flutter/material.dart';

class CustomPopupHeader extends StatefulWidget {
  final bool isVisible;
  final String headerText;
  const CustomPopupHeader({
    super.key,
    required this.isVisible,
    required this.headerText,
  });

  @override
  State<CustomPopupHeader> createState() => _CustomPopupHeaderState();
}

class _CustomPopupHeaderState extends State<CustomPopupHeader> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.headerText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent.shade700,
            ),
          ),
          Visibility(
            visible: widget.isVisible,
            child: Row(
              children: [
                Text(
                  'Event Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurpleAccent.shade700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 5),
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isChecked = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
