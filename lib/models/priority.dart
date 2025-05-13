import 'package:flutter/material.dart';

class Priority {
  static const List<int> priorities = [1, 2, 3];

  static IconData getIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.flag;
      case 2:
        return Icons.flag;
      case 3:
        return Icons.flag;
      default:
        return Icons.flag;
    }
  }

  static Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static String getText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return '';
    }
  }
}