import 'package:expense_manager/database/expense_category_database.dart';
import 'package:expense_manager/database/expense_sub_category_database.dart';
import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';
import 'package:flutter/material.dart';

class ExpenseCategoryProvider extends ChangeNotifier {
  final ExpenseCategoryDBService _categoryService = ExpenseCategoryDBService();
  final ExpenseSubCategoryDBService _subCategoryService =
      ExpenseSubCategoryDBService();

  List<ExpenseCategoryModel> _categories = [];
  List<ExpenseCategoryModel> get categories => _categories;

  final _subCategories = {};
  List<ExpenseSubCategoryModel> subCategoriesForCategory(int categoryId) =>
      _subCategories[categoryId] ?? [];

  // Fetch all categories from DB
  Future<void> fetchCategories() async {
    _categories = await _categoryService.getAll();
    notifyListeners();
  }

  // Fetch subcategories for a category
  Future<void> fetchSubCategories(int categoryId) async {
    _subCategories[categoryId] = await _subCategoryService.getByCategoryId(
      categoryId,
    );
    notifyListeners();
  }

  // Insert new category
  Future<void> addCategory(ExpenseCategoryModel category) async {
    await _categoryService.insert(category);
    await fetchCategories();
  }

  // Insert new subcategory
  Future<void> addSubCategory(ExpenseSubCategoryModel subCategory) async {
    await _subCategoryService.insert(subCategory);
    await fetchSubCategories(subCategory.categoryId!);
  }

  // Update category
  Future<void> updateCategory(ExpenseCategoryModel category) async {
    await _categoryService.update(category);
    await fetchCategories();
  }

  // Update subcategory
  Future<void> updateSubCategory(ExpenseSubCategoryModel subCategory) async {
    await _subCategoryService.update(subCategory);
    await fetchSubCategories(subCategory.categoryId!);
  }

  // Delete category and its subcategories (assuming foreign key cascade)
  Future<void> deleteCategory(int id) async {
    await _categoryService.delete(id);
    _subCategories.remove(id);
    await fetchCategories();
  }

  // Delete subcategory
  Future<void> deleteSubCategory(int id, int categoryId) async {
    await _subCategoryService.delete(id);
    await fetchSubCategories(categoryId);
  }

  // Helper: Get Icon Widget from icon string (similar to your ListOfExpenses)
  Widget getIconWidget(String? icon, {double size = 28}) {
    // You can implement a mapping here or use emoji/text icons like your example
    if (icon == null || icon.isEmpty) {
      return Text('❓', style: TextStyle(fontSize: size));
    }
    return Text(icon, style: TextStyle(fontSize: size));
  }

  /// Get category ID from name
  int? getCategoryIdByName(String name) {
    try {
      return _categories
          .firstWhere((c) => c.name?.toLowerCase() == name.toLowerCase())
          .id;
    } catch (_) {
      return null;
    }
  }

  /// Get category name from ID
  String getCategoryNameById(int? id) {
    if (id == null) return "Unknown";
    try {
      return _categories.firstWhere((c) => c.id == id).name ?? "Unknown";
    } catch (_) {
      return "Unknown";
    }
  }

  /// Get icon string from category name
  String getCategoryIconByName(String name) {
    try {
      return _categories
              .firstWhere((c) => c.name?.toLowerCase() == name.toLowerCase())
              .icon ??
          "❓";
    } catch (_) {
      return "❓";
    }
  }

  /// Get icon string from category ID
  String getCategoryIconById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id).icon ?? "❓";
    } catch (_) {
      return "❓";
    }
  }

  /// Get list of category names for dropdown/search
  List<String> get categoryNames =>
      _categories.map((e) => e.name ?? '').toList();
}
