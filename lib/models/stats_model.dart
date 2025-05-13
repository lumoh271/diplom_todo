import 'package:flutter_hive_tdo/models/category.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class CategoryStats {
  final String categoryId;
  final String categoryName;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;

  CategoryStats({
    required this.categoryId,
    required this.categoryName,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
  });
}

class StatsRepository {
  static List<CategoryStats> getCategoryStats(Box<Task> taskBox, List<Category> categories) {
    return categories.map((category) {
      final tasks = taskBox.values.where((task) => task.categoryId == category.id).toList();
      final total = tasks.length;
      final completed = tasks.where((t) => t.isCompleted).length;
      final rate = total > 0 ? (completed / total).toDouble() : 0.0;

      return CategoryStats(
        categoryId: category.id,
        categoryName: category.name,
        totalTasks: total,
        completedTasks: completed,
        completionRate: rate,
      );
    }).toList();
  }
}