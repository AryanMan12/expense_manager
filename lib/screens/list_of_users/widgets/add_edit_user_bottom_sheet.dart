// lib/screens/list_of_users/widgets/add_edit_user_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:expense_manager/models/users_db_model.dart';
import 'package:expense_manager/database/users_database.dart';

class AddEditUserBottomSheet extends StatefulWidget {
  final UserModel? user; // null = add, non-null = edit
  final VoidCallback onSaved; // callback to refresh list

  const AddEditUserBottomSheet({super.key, this.user, required this.onSaved});

  @override
  State<AddEditUserBottomSheet> createState() => _AddEditUserBottomSheetState();
}

class _AddEditUserBottomSheetState extends State<AddEditUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController borrowedController;
  late TextEditingController lendController;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    borrowedController = TextEditingController(
      text: widget.user?.moneyBorrowed?.toString() ?? '0',
    );
    lendController = TextEditingController(
      text: widget.user?.moneyLend?.toString() ?? '0',
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final db = UserDBService();
    final name = nameController.text.trim();
    final borrowed = double.tryParse(borrowedController.text) ?? 0;
    final lend = double.tryParse(lendController.text) ?? 0;
    final now = DateTime.now().toIso8601String();

    if (isEdit) {
      final updatedUser = widget.user!.copyWith(
        name: name,
        moneyBorrowed: borrowed,
        moneyLend: lend,
        modifiedDate: now,
      );
      await db.update(updatedUser);
    } else {
      final newUser = UserModel(
        name: name,
        moneyBorrowed: borrowed,
        moneyLend: lend,
        total: lend - borrowed,
        createdDate: now,
        modifiedDate: now,
        isActive: true,
      );
      await db.insert(newUser);
    }

    widget.onSaved();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? "Edit User" : "Add User",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: borrowedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Borrowed (₹)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lendController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Lent (₹)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveUser,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? "Save Changes" : "Add User"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
