import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditCategoryOrSubCategoryScreen extends StatefulWidget {
  final ExpenseCategoryModel? categoryToEdit;
  final ExpenseSubCategoryModel? subCategoryToEdit;
  final int? parentCategoryId;

  const AddEditCategoryOrSubCategoryScreen({
    super.key,
    this.categoryToEdit,
    this.subCategoryToEdit,
    this.parentCategoryId,
  });

  @override
  State<AddEditCategoryOrSubCategoryScreen> createState() =>
      _AddEditCategoryOrSubCategoryScreenState();
}

class _AddEditCategoryOrSubCategoryScreenState
    extends State<AddEditCategoryOrSubCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool get isEditing =>
      widget.categoryToEdit != null || widget.subCategoryToEdit != null;
  bool get isSubCategory =>
      widget.subCategoryToEdit != null || widget.parentCategoryId != null;

  @override
  void initState() {
    super.initState();
    if (isSubCategory && widget.subCategoryToEdit != null) {
      _nameController.text = widget.subCategoryToEdit!.name ?? '';
      _iconController.text = widget.subCategoryToEdit!.icon ?? '';
      _tagsController.text = widget.subCategoryToEdit!.tags ?? '';
    } else if (!isSubCategory && widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name ?? '';
      _iconController.text = widget.categoryToEdit!.icon ?? '';
      _tagsController.text = widget.categoryToEdit!.tags ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    final provider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty.")));
      return;
    }

    if (isSubCategory) {
      final subCat = ExpenseSubCategoryModel(
        id: widget.subCategoryToEdit?.id,
        categoryId:
            widget.parentCategoryId ?? widget.subCategoryToEdit!.categoryId,
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        tags: _tagsController.text.trim(),
        createdDate: widget.subCategoryToEdit?.createdDate ?? now,
        modifiedDate: now,
      );

      final allCategories = provider.categories;
      bool isDuplicateSubCategory = false;
      String? foundCategoryName;

      for (final cat in allCategories) {
        final subCats = provider.subCategoriesForCategory(cat.id!);
        for (final sub in subCats) {
          final isSameName = sub.name?.toLowerCase() == name.toLowerCase();
          final isSameId = subCat.id == sub.id;

          if (isSameName && !isSameId) {
            isDuplicateSubCategory = true;
            foundCategoryName = cat.name;
            break;
          }
        }
        if (isDuplicateSubCategory) break;
      }

      if (isDuplicateSubCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Subcategory '$name' already exists under '$foundCategoryName'",
            ),
          ),
        );
        return;
      }

      if (isEditing) {
        await provider.updateSubCategory(subCat);
      } else {
        await provider.addSubCategory(subCat);
      }
    } else {
      final cat = ExpenseCategoryModel(
        id: widget.categoryToEdit?.id,
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        tags: _tagsController.text.trim(),
        createdDate: widget.categoryToEdit?.createdDate ?? now,
        modifiedDate: now,
      );

      final existingCategories = provider.categories;

      final isDuplicateCategory = existingCategories.any((cat) {
        final isSameName = cat.name?.toLowerCase() == name.toLowerCase();
        final isSameId = widget.categoryToEdit?.id == cat.id;
        return isSameName && !isSameId;
      });

      if (isDuplicateCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category '$name' already exists.")),
        );
        return;
      }

      if (isEditing) {
        await provider.updateCategory(cat);
      } else {
        await provider.addCategory(cat);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isSubCategory
        ? (isEditing ? "Edit Subcategory" : "Add Subcategory")
        : (isEditing ? "Edit Category" : "Add Category");

    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader(
            screenName: title,
            hasBack: true,
            onBackClick: (callback) {
              if (!callback) return;
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? "Please enter a name"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _iconController,
                      decoration: const InputDecoration(
                        labelText: "Icon (emoji or text)",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: "Tags (comma-separated)",
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _onSave,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),

                    if (isEditing && isSubCategory) const SizedBox(height: 20),
                    if (isEditing && isSubCategory)
                      TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Subcategory"),
                              content: const Text(
                                "Are you sure you want to delete this subcategory?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;
                          if (context.mounted) {
                            final provider =
                                Provider.of<ExpenseCategoryProvider>(
                                  context,
                                  listen: false,
                                );
                            await provider.deleteSubCategory(
                              widget.subCategoryToEdit!.id!,
                              widget.subCategoryToEdit!.categoryId!,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
