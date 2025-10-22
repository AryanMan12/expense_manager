import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:expense_manager/providers/expense_category_provider.dart';
import 'package:expense_manager/screens/list_of_expense_group/add_edit_category_subcategory_screen.dart';
import 'package:expense_manager/widgets/navigation_bars/custom_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubCategoryListScreen extends StatefulWidget {
  final ExpenseCategoryModel category;

  const SubCategoryListScreen({super.key, required this.category});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    final provider = Provider.of<ExpenseCategoryProvider>(
      context,
      listen: false,
    );
    await provider.fetchSubCategories(widget.category.id!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader(
            screenName: category.name ?? "Sub Categories",
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
                  builder: (_) => AddEditCategoryOrSubCategoryScreen(
                    parentCategoryId: category.id,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<ExpenseCategoryProvider>(
                    builder: (context, provider, _) {
                      final subCategories = provider.subCategoriesForCategory(
                        category.id!,
                      );

                      if (subCategories.isEmpty) {
                        return const Center(
                          child: Text("No subcategories found."),
                        );
                      }

                      return ListView.builder(
                        itemCount: subCategories.length,
                        itemBuilder: (context, index) {
                          final subCat = subCategories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: provider.getIconWidget(subCat.icon),
                              title: Text(subCat.name ?? ''),
                              subtitle: Text(subCat.tags ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditCategoryOrSubCategoryScreen(
                                          categoryToEdit: category,
                                          subCategoryToEdit: subCat,
                                        ),
                                  ),
                                );
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
}
