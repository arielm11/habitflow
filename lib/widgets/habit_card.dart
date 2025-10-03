// lib/widgets/habit_card.dart

import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';
import '../data/models/habito_model.dart';

class HabitCard extends StatelessWidget {
  final Habito habito;
  // --- ALTERAÇÃO 1: Simplificar o construtor ---
  // Os campos 'habitName' e 'description' foram removidos
  // porque já temos essa informação dentro do objeto 'habito'.
  final IconData icon;
  final bool isCompleted;
  final Function(bool?)? onChanged;

  const HabitCard({
    super.key,
    required this.habito, // Agora só precisamos do objeto completo
    required this.icon,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // A sua lógica está perfeita e será mantida.
    String tituloExibido = habito.nome;
    if (habito.metaValor != null && habito.metaValor!.isNotEmpty) {
      // O "0/" é um placeholder para o progresso futuro
      tituloExibido = '${habito.nome} (0/${habito.metaValor})';
    }

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
          // --- ALTERAÇÃO 2: Usar a variável correta no título ---
          title: Text(
            tituloExibido, // Usamos a variável que criamos com a lógica da meta.
            style: const TextStyle(
              color: AppColors.graphite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          // --- ALTERAÇÃO 3: Obter a descrição diretamente do objeto 'habito' ---
          subtitle: (habito.descricao != null && habito.descricao!.isNotEmpty)
              ? Text(
                  habito.descricao!, // Usamos a descrição que vem do objeto.
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