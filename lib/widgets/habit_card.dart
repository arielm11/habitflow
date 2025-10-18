import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';
import '../data/models/habito_model.dart';
import 'dart:math'; // Precisamos da biblioteca 'math' para usar a função 'min'.

class HabitCard extends StatelessWidget {
  // --- NOVOS PARÂMETROS ---
  final Habito habito;
  final bool isCompleted; // Continua sendo usado para hábitos 'Feito/Não Feito'
  final double progress; // Novo! Recebe o progresso atual para metas numéricas
  final Function(bool?)?
      onCheckboxChanged; // Nome mais claro para o callback do checkbox
  final VoidCallback? onTap; // Ação de clique para abrir o pop-up

  const HabitCard({
    super.key,
    required this.habito,
    required this.isCompleted,
    required this.progress,
    required this.onCheckboxChanged,
    this.onTap,
  });

  // --- MELHORIA 1: ADICIONAR A FUNÇÃO DE ÍCONE INTELIGENTE ---
  // Esta função, que você já tinha criado, é resgatada.
  // Ela olha para o 'tipoMeta' do hábito e retorna o ícone apropriado.
  IconData _getIconForHabit() {
    switch (habito.tipoMeta) {
      case 'Meta Numérica':
        return Icons.format_list_numbered; // Ícone para metas com números
      case 'Duração':
        return Icons.timer_outlined; // Ícone para metas de tempo
      case 'Feito/Não Feito':
      default:
        return Icons.check_circle_outline; // Ícone padrão
    }
  }

  /// Função auxiliar para extrair o VALOR NUMÉRICO da meta.
  /// Ex: de "10 páginas", ela retorna o valor 10.0.
  double _getMetaValue() {
    if (habito.metaValor == null || habito.metaValor!.isEmpty) {
      return 1.0; // Valor padrão para evitar divisão por zero na barra de progresso
    }
    // Pega a primeira parte da string (o número), substitui vírgula por ponto
    // para garantir a conversão, e tenta converter para double.
    final valorString =
        habito.metaValor?.split(' ').first.replaceAll(',', '.') ?? '1.0';
    return double.tryParse(valorString) ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE CONTROLE VISUAL ---

    // 1. Determina se o hábito é numérico ou simples.
    final bool isNumericGoal =
        habito.tipoMeta == 'Meta Numérica' || habito.tipoMeta == 'Duração';

    // 2. Calcula o alvo da meta.
    final double metaTarget = isNumericGoal ? _getMetaValue() : 1.0;

    // 3. Verifica se a meta foi concluída.
    final bool goalMet = isNumericGoal ? (progress >= metaTarget) : isCompleted;

    // 4. Define estilos dinâmicos baseados na conclusão da meta.
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
            // --- LINHA PRINCIPAL DE INFORMAÇÃO ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- MELHORIA 2: USAR O ÍCONE DINÂMICO ---
                // Trocamos o ícone fixo 'Icons.flag_outlined' pela chamada à nossa nova função.
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
