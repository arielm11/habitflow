import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';

// Card de Hábito
class HabitCard extends StatelessWidget {
  final String habitName;
  final IconData icon;
  final bool isCompleted;
  final Function(bool?)? onChanged;

  const HabitCard({
    super.key,
    required this.habitName,
    required this.icon,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // Titulo
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
          // Checkbox
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
