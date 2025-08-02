import 'package:flutter/material.dart';

class PriorityPicker extends StatelessWidget {
  final int currentPriority;
  final Function(int) onChanged;

  const PriorityPicker({
    super.key,
    required this.currentPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final priority = index + 1;
            return ChoiceChip(
              label: Text('$priority'),
              selected: currentPriority == priority,
              onSelected: (selected) => onChanged(priority),
            );
          }),
        ),
      ],
    );
  }
}