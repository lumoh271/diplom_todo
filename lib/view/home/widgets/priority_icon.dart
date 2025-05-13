import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/models/priority.dart';

class PriorityIcon extends StatelessWidget {
  final int priority;

  const PriorityIcon({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Priority.getIcon(priority),
      color: Priority.getColor(priority),
      size: 18,
    );
  }
}