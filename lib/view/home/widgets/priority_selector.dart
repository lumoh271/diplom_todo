import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/models/priority.dart';

class PrioritySelector extends StatefulWidget {
  final int initialPriority;
  final ValueChanged<int> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.initialPriority,
    required this.onPriorityChanged,
  });

  @override
  _PrioritySelectorState createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends State<PrioritySelector> {
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Priority.priorities.map((priority) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPriority = priority;
            });
            widget.onPriorityChanged(priority);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Priority.getIcon(priority),
                color: _selectedPriority == priority
                    ? Priority.getColor(priority)
                    : Colors.grey,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                Priority.getText(priority),
                style: TextStyle(
                  color: _selectedPriority == priority
                      ? Priority.getColor(priority)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}