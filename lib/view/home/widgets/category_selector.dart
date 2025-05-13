import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/utils/colors.dart';
import 'package:provider/provider.dart';
import '../../../data/category_repository.dart';
import '../../../models/category.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<Category> onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryRepository = Provider.of<CategoryRepository>(context);
    final categories = categoryRepository.getAllCategories();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 18),
              const SizedBox(width: 6),
              Text(category.name),
            ],
          ),
          selected: selectedCategoryId == category.id,
          selectedColor: MyColors.primaryColor.withOpacity(.9),
          onSelected: (selected) {
            if (selected) {
              onCategorySelected(category);
            }
          },
        );
      }).toList(),
    );
  }
}