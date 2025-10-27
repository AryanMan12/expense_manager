// user_details_screen.dart
import 'package:flutter/material.dart';
import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/database/users_database.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late TextEditingController borrowedController;
  late TextEditingController lendController;
  late TextEditingController totalController;

  @override
  void initState() {
    super.initState();
    borrowedController = TextEditingController(
      text: widget.user.moneyBorrowed?.toString() ?? '0',
    );
    lendController = TextEditingController(
      text: widget.user.moneyLend?.toString() ?? '0',
    );
    totalController = TextEditingController(
      text: widget.user.total?.toString() ?? '0',
    );
  }

  Future<void> _saveChanges() async {
    final updatedUser = widget.user.copyWith(
      moneyBorrowed: double.tryParse(borrowedController.text) ?? 0,
      moneyLend: double.tryParse(lendController.text) ?? 0,
      total: double.tryParse(totalController.text) ?? 0,
      modifiedDate: DateTime.now().toIso8601String(),
    );

    await UserDBService().update(updatedUser);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User updated successfully")),
      );
      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance =
        (double.tryParse(lendController.text) ?? 0) -
        (double.tryParse(borrowedController.text) ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name ?? "User Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Name: ${widget.user.name}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildField("Total", totalController),
            _buildField("Borrowed", borrowedController),
            _buildField("Lent", lendController),
            const SizedBox(height: 10),
            Text(
              "Net Balance: ₹${balance.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 18,
                color: balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
