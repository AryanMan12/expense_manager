import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/screens/list_of_expense_group/add_edit_category_subcategory_screen.dart';
import 'package:expense_manager/screens/list_of_expense_group/sub_category_list_screen.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseCategoryListScreen extends StatefulWidget {
  const ExpenseCategoryListScreen({super.key});

  @override
  State<ExpenseCategoryListScreen> createState() =>
      _ExpenseCategoryListScreenState();
}

class _ExpenseCategoryListScreenState extends State<ExpenseCategoryListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final provider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );
    await provider.fetchCategories();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader(
            screenName: "Expense Groups",
            hasBack: true,
            hasAdd: true,
            onBackClick: (callback) {
              if (!callback) return;
              Navigator.of(context).pop();
            },
            onAddClick: (callback) {
              if (!callback) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditCategoryOrSubCategoryScreen(),
                ),
              );
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<ExpenseCategoryProvider>(
                    builder: (context, provider, _) {
                      final categories = provider.categories;

                      if (categories.isEmpty) {
                        return const Center(
                          child: Text("No categories found."),
                        );
                      }

                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: provider.getIconWidget(category.icon),
                              title: Text(category.name ?? ''),
                              subtitle: Text(category.tags ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubCategoryListScreen(
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                _showCategoryOptions(context, category);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCategoryOptions(
    BuildContext context,
    ExpenseCategoryModel category,
  ) {
    final provider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditCategoryOrSubCategoryScreen(
                        categoryToEdit: category,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete"),
                onTap: () async {
                  Navigator.pop(context);
                  await provider.deleteCategory(category.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
