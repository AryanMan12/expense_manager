import 'package:expense_manager/utils/ui_callbacks.dart';
import 'package:flutter/material.dart';

class CustomScreenHeader extends StatelessWidget {
  final String screenName;
  final bool? hasBack;
  final bool? hasAdd;
  final BoolCallback? onBackClick;
  final BoolCallback? onAddClick;
  const CustomScreenHeader({
    super.key,
    required this.screenName,
    this.hasBack,
    this.onBackClick,
    this.hasAdd,
    this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Visibility(
                      visible: hasBack ?? false,
                      child: InkWell(
                        onTap: () => onBackClick!(true),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Icon(Icons.arrow_back_ios_rounded, size: 24),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        screenName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: hasAdd ?? false,
                child: InkWell(
                  onTap: () => onAddClick!(true),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(Icons.add, size: 24),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 2, thickness: 2, color: Colors.deepPurpleAccent),
        ],
      ),
    );
  }
}
