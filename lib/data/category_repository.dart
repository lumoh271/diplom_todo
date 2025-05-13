import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryRepository {
  static const boxName = "categoriesBox";
  final Box<Category> box = Hive.box<Category>(boxName);

  CategoryRepository() {
    _initDefaultCategories();
  }

  Future<void> _initDefaultCategories() async {
    if (box.isEmpty) {
      final defaultCategories = [
        Category(id: 'personal', name: 'Personal', iconCode: Icons.person.codePoint),
        Category(id: 'job', name: 'Job', iconCode: Icons.work.codePoint),
        Category(id: 'education', name: 'Education', iconCode: Icons.school.codePoint),
        Category(id: 'family', name: 'Family', iconCode: Icons.family_restroom.codePoint),
        Category(id: 'sport', name: 'Sport', iconCode: Icons.sports_soccer.codePoint),
        Category(id: 'entertainment', name: 'Entertainment', iconCode: Icons.movie.codePoint),
      ];

      await box.addAll(defaultCategories);
    }
  }

  List<Category> getAllCategories() {
    return box.values.toList();
  }

  Category? getCategoryById(String id) {
    return box.values.firstWhere((cat) => cat.id == id);
  }
}