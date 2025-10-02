// lib/widgets/habit_card.dart

import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';

class HabitCard extends StatelessWidget {
  final String habitName;
  final String? description;
  final IconData icon;
  final bool isCompleted;
  final Function(bool?)? onChanged;

  const HabitCard({
    super.key,
    required this.habitName,
    this.description,
    required this.icon,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // É apenas o nosso Card original, sem nenhuma funcionalidade de deslizar.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: AppColors.seaGreen,
            size: 32,
          ),
          title: Text(
            habitName,
            style: const TextStyle(
              color: AppColors.graphite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: (description != null && description!.isNotEmpty)
              ? Text(
                  description!,
                  style: TextStyle(color: AppColors.graphite.withOpacity(0.8)),
                )
              : null,
          trailing: Checkbox(
            value: isCompleted,
            onChanged: onChanged,
            activeColor: AppColors.teal,
          ),
        ),
      ),
    );
  }
}
