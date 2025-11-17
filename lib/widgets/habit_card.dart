import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';
import '../data/models/habito_model.dart';
import 'dart:math';

class HabitCard extends StatelessWidget {
  final Habito habito;
  final bool isCompleted;
  final double progress;
  final Function(bool?)? onCheckboxChanged;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habito,
    required this.isCompleted,
    required this.progress,
    required this.onCheckboxChanged,
    this.onTap,
  });

  IconData _getIconForHabit() {
    switch (habito.tipoMeta) {
      case 'Meta Numérica':
        return Icons.format_list_numbered;
      case 'Duração':
        return Icons.timer_outlined;
      case 'Feito/Não Feito':
      default:
        return Icons.check_circle_outline;
    }
  }

  double _getMetaValue() {
    if (habito.metaValor == null || habito.metaValor!.isEmpty) {
      return 1.0;
    }

    final valorString =
        habito.metaValor?.split(' ').first.replaceAll(',', '.') ?? '1.0';
    return double.tryParse(valorString) ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isNumericGoal =
        habito.tipoMeta == 'Meta Numérica' || habito.tipoMeta == 'Duração';

    final double metaTarget = isNumericGoal ? _getMetaValue() : 1.0;

    final bool goalMet = isNumericGoal ? (progress >= metaTarget) : isCompleted;

    final Color activeColor = AppColors.seaGreen;
    final Color inactiveColor = AppColors.graphite.withOpacity(0.7);
    final Color dynamicColor = goalMet ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_getIconForHabit(), color: dynamicColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habito.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.graphite,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // --- WIDGET DINÂMICO (DIREITA) ---
                if (!isNumericGoal)
                  Checkbox(
                    value: isCompleted,
                    onChanged: onCheckboxChanged,
                    activeColor: AppColors.teal,
                  )
                else
                  Text(
                    goalMet
                        ? "Meta Concluída!"
                        : "${progress.toStringAsFixed(1)} / ${metaTarget.toStringAsFixed(1)}",
                    style: TextStyle(
                      color: dynamicColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),

            // --- BARRA DE PROGRESSO VISUAL ---
            if (isNumericGoal) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: min(progress / metaTarget, 1.0),
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(dynamicColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
