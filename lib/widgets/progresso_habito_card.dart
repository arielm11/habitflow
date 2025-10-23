// lib/widgets/progresso_habito_card.dart

import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';

class ProgressoHabitoCard extends StatelessWidget {
  final IconData icon;
  final String nome;
  final int metaDias;
  final int diasConcluidos;

  const ProgressoHabitoCard({
    super.key,
    required this.icon,
    required this.nome,
    required this.metaDias,
    required this.diasConcluidos,
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se a meta do hábito foi concluída.
    final bool isCompleto = diasConcluidos >= metaDias;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ícone do Hábito
            Icon(icon, size: 40, color: isCompleto ? AppColors.seaGreen : AppColors.teal),
            const SizedBox(width: 16),

            // Coluna com os textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Por $metaDias dias: $nome',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.graphite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Se a meta estiver completa, mostra a mensagem de parabéns.
                  if (isCompleto)
                    const Text(
                      'Muito Bem! meta batida!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.seaGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    '$diasConcluidos/$metaDias',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.graphite.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            const SizedBox(width: 16),
            Checkbox(
              value: isCompleto,
              onChanged: null, // Deixamos nulo para ser apenas visual
              shape: const CircleBorder(),
              activeColor: AppColors.seaGreen,
              // Usamos `fillColor` para controlar a cor em ambos os estados
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.seaGreen; // Cor quando selecionado
                  }
                  return AppColors.graphite.withOpacity(0.2); // Cor quando não selecionado
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}