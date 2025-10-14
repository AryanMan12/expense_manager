import 'package:flutter/material.dart';

class CustomAutofillTextBox extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPasswordField;
  final IconData icon;
  final TextInputType inputType;
  final Color? iconColor;
  const CustomAutofillTextBox({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
    this.icon = Icons.text_fields,
    this.inputType = TextInputType.text,
    this.iconColor,
  });

  @override
  State<CustomAutofillTextBox> createState() => _CustomAutofillTextBoxState();
}

class _CustomAutofillTextBoxState extends State<CustomAutofillTextBox> {
  List<String> suggestions = ["Aryan", "Yana", "Home", "Office"];
  late List<String> filteredSuggestions;

  @override
  void initState() {
    super.initState();
    filteredSuggestions = suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (filteredSuggestions.isNotEmpty && widget.controller.text.isNotEmpty)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 179, 136, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredSuggestions[index]),
                    onTap: () {
                      widget.controller.text = filteredSuggestions[index];
                      setState(() {
                        suggestions.add(filteredSuggestions[index]);
                        filteredSuggestions = suggestions;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        Column(
          children: [
            TextField(
              controller: widget.controller,
              obscureText: widget.isPasswordField,
              onChanged: (text) {
                setState(() {
                  filteredSuggestions = suggestions
                      .where(
                        (item) =>
                            item.toLowerCase().contains(text.toLowerCase()),
                      )
                      .toList();
                });
              },
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              keyboardType: widget.inputType,
              decoration: InputDecoration(
                prefixIcon: Icon(widget.icon, color: widget.iconColor),
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
