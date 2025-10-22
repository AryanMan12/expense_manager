import 'package:expense_manager/database/expense_category_database.dart';
import 'package:expense_manager/database/expense_sub_category_database.dart';
import 'package:expense_manager/models/expense_category_db_model.dart';
import 'package:expense_manager/models/expense_sub_category_db_model.dart';

class DbInitData {
  static Future<void> initializeCategoryAndSubCategory() async {
    final expenseCategoryDB = ExpenseCategoryDBService();
    final expenseSubCategoryDB = ExpenseSubCategoryDBService();

    final existingCategories = await expenseCategoryDB.getAll();
    if (existingCategories.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();

    // 1. Insert all categories
    final Map<String, List<String>> categoryData = {
      "Food": [
        "Groceries",
        "Snacks",
        "Beverages",
        "Dining Out / Family Dine Out",
        "Lunch",
        "Dinner",
      ],
      "Transportation": [
        "Fuel",
        "Public Transport",
        "Cab / Ride Sharing",
        "Vehicle Maintenance",
        "Parking & Tolls",
      ],
      "Housing / Living": [
        "Rent / Mortgage",
        "Utilities (Electricity, Water, Internet, Gas)",
        "Household Supplies",
        "Repairs & Maintenance",
      ],
      "Work / Education": [
        "Courses / Online Learning",
        "Stationery / Supplies",
        "Tuition Fees",
        "Books & Subscriptions",
      ],
      "Finance": [
        "Loans / EMIs",
        "Credit Card Payments",
        "Savings",
        "Investments",
        "Insurance",
      ],
      "Shopping": [
        "Clothing",
        "Electronics",
        "Home Essentials",
        "Miscellaneous Shopping",
      ],
      "Entertainment & Lifestyle": [
        "Movies / Shows",
        "Parties / Social Events",
        "Subscriptions (Streaming, Apps)",
        "Hobbies / Games",
      ],
      "Travel": [
        "Flights / Trains",
        "Hotels / Stays",
        "Food on Trip",
        "Local Travel",
        "Travel Shopping",
      ],
      "Personal Care & Health": [
        "Salon / Grooming",
        "Medical Bills",
        "Fitness / Gym",
        "Health Insurance",
        "Medicines",
      ],
      "Gifts & Donations": ["Gifts", "Donations", "Charity Events"],
      "Luxury": [
        "Jewellery & Watches",
        "High-end Fashion",
        "Premium Tech Gadgets",
        "Luxury Holidays",
        "Spa / Premium Services",
      ],
      "Personal": [
        "Self-Care",
        "Hobbies",
        "Personal Development",
        "Lifestyle Upgrades",
        "Miscellaneous Personal",
      ],
      "Miscellaneous": ["Uncategorized", "Others"],
    };

    // Assign default emoji icons per category (you can customize this)
    final Map<String, String> categoryIcons = {
      "Food": "🍔",
      "Transportation": "🚗",
      "Housing / Living": "🏠",
      "Work / Education": "📚",
      "Finance": "💰",
      "Shopping": "🛍️",
      "Entertainment & Lifestyle": "🎉",
      "Travel": "✈️",
      "Personal Care & Health": "💅",
      "Gifts & Donations": "🎁",
      "Luxury": "💎",
      "Personal": "🧘",
      "Miscellaneous": "🔖",
    };

    // 2. Insert all categories and store their IDs
    final Map<String, int> categoryIds = {};
    for (final entry in categoryData.entries) {
      final name = entry.key;
      final cat = ExpenseCategoryModel(
        name: name,
        icon: categoryIcons[name] ?? "❓",
        tags: name.toLowerCase().replaceAll(" ", ","),
        createdDate: now,
        modifiedDate: now,
      );
      await expenseCategoryDB.insert(cat);
      final saved = await expenseCategoryDB.getByName(name);
      if (saved != null) {
        categoryIds[name] = saved.id!;
      }
    }

    // 3. Insert all subcategories
    for (final entry in categoryData.entries) {
      final catName = entry.key;
      final subCats = entry.value;
      final catId = categoryIds[catName];
      if (catId == null) continue;

      for (final sub in subCats) {
        final subCat = ExpenseSubCategoryModel(
          categoryId: catId,
          name: sub,
          icon: "📂",
          tags: sub.toLowerCase().replaceAll(" ", ","),
          createdDate: now,
          modifiedDate: now,
        );
        await expenseSubCategoryDB.insert(subCat);
      }
    }
  }
}
