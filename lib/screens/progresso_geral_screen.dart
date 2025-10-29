// lib/screens/progresso_geral_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/data/providers/habito_provider.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/progresso_habito_card.dart';
import 'package:provider/provider.dart';

class ProgressoGeralScreen extends StatefulWidget {
  const ProgressoGeralScreen({super.key});

  @override
  State<ProgressoGeralScreen> createState() => _ProgressoGeralScreenState();
}

class _ProgressoGeralScreenState extends State<ProgressoGeralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitoProvider>().carregarDadosProgresso();
    });
  }

  IconData _getIconForHabit(Habito habito) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitoProvider>();

    final habitosComPeriodo = provider.habitosComPeriodo;
    final habitosContinuos = provider.habitosContinuos;

    final habitosEmProgresso =
        habitosComPeriodo.where((p) => p.diasConcluidos < p.metaDias).toList();
    final habitosConcluidos =
        habitosComPeriodo.where((p) => p.diasConcluidos >= p.metaDias).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progresso de Metas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: provider.isLoadingProgresso
            ? const Center(child: CircularProgressIndicator())
            : (habitosEmProgresso.isEmpty &&
                    habitosConcluidos.isEmpty &&
                    habitosContinuos.isEmpty)
                ? const Center(
                    child: Text(
                      "Nenhum hábito com data de início encontrado.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.graphite),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.carregarDadosProgresso(),
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        const Text(
                          'Performance (Últimos 7 dias)',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.graphite),
                        ),
                        const SizedBox(height: 16),
                        _GraficoSemanal(
                            performance: provider.performanceSemanal),
                        const SizedBox(height: 30),

                        // --- Seção 1: Progresso de Metas ---
                        if (habitosEmProgresso.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
                            child: Text('Progresso de Metas',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.graphite)),
                          ),
                          ...habitosEmProgresso
                              .map((item) => ProgressoHabitoCard(
                                    icon: _getIconForHabit(item.habito),
                                    nome: item.habito.nome,
                                    metaDias: item.metaDias,
                                    diasConcluidos: item.diasConcluidos,
                                  )),
                          const SizedBox(height: 30),
                        ],

                        // --- Seção 2: Metas batidas ---
                        if (habitosConcluidos.isNotEmpty) ...[
                          const Text('Metas batidas:',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.graphite)),
                          const SizedBox(height: 10),
                          ...habitosConcluidos
                              .map((item) => ProgressoHabitoCard(
                                    icon: _getIconForHabit(item.habito),
                                    nome: item.habito.nome,
                                    metaDias: item.metaDias,
                                    diasConcluidos: item.diasConcluidos,
                                  )),
                          const SizedBox(height: 30),
                        ],

                        // --- Seção 3: Hábitos Contínuos ---
                        if (habitosContinuos.isNotEmpty) ...[
                          const Text('Hábitos Contínuos',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.graphite)),
                          const SizedBox(height: 10),
                          ...habitosContinuos
                              .map((item) => _ProgressoContinuoCard(
                                    icon: _getIconForHabit(item.habito),
                                    nome: item.habito.nome,
                                    diasConcluidos: item.diasConcluidos,
                                  )),
                        ]
                      ],
                    ),
                  ),
      ),
    );
  }
}

// --- WIDGET DO CARD CONTÍNUO ---
class _ProgressoContinuoCard extends StatelessWidget {
  final IconData icon;
  final String nome;
  final int diasConcluidos;

  const _ProgressoContinuoCard({
    required this.icon,
    required this.nome,
    required this.diasConcluidos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.graphite, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nome,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.graphite,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "Total: $diasConcluidos dias",
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.seaGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// GRÁFICO DE BARRAS (Tarefa 4) ---
class _GraficoSemanal extends StatelessWidget {
  final List<PerformanceDia> performance;
  const _GraficoSemanal({required this.performance});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7, // Proporção do gráfico
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100, // Gráfico vai de 0% a 100%
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (BarChartGroupData group) {
                    return AppColors.graphite;
                  },
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final dia = performance[groupIndex];
                    return BarTooltipItem(
                      '${(dia.taxaConclusao * 100).toStringAsFixed(0)}%',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Certifica que o índice está dentro dos limites
                      if (value.toInt() < 0 ||
                          value.toInt() >= performance.length) {
                        return const Text('');
                      }
                      final dia = performance[value.toInt()];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          dia.diaSemana,
                          style: const TextStyle(
                            color: AppColors.graphite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == 50 || value == 100) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                              color: AppColors.graphite, fontSize: 12),
                          textAlign: TextAlign.left,
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.graphite.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              barGroups: performance.asMap().entries.map((entry) {
                final index = entry.key;
                final dia = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: dia.taxaConclusao * 100,
                      color: dia.taxaConclusao > 0.7
                          ? AppColors.seaGreen
                          : AppColors.teal,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
