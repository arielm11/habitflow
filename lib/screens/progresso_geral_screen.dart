// lib/screens/progresso_geral_screen.dart

import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/progresso_habito_card.dart';

// --- (Nenhuma mudança aqui) ---
class ProgressoData {
  final Habito habito;
  final int metaDias;
  final int diasConcluidos;

  ProgressoData({
    required this.habito,
    required this.metaDias,
    required this.diasConcluidos,
  });
}

// --- (Nenhuma mudança aqui) ---
class ProgressoGeralScreen extends StatefulWidget {
  const ProgressoGeralScreen({super.key});

  @override
  State<ProgressoGeralScreen> createState() => _ProgressoGeralScreenState();
}

class _ProgressoGeralScreenState extends State<ProgressoGeralScreen> {
  bool _isLoading = true;
  List<ProgressoData> _listaDeProgresso = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- (Nenhuma mudança aqui) ---
  Future<void> _loadData() async {
    final habitosMap = await DatabaseHelper.instance.getHabitosDePeriodo();
    final habitos = habitosMap.map((map) => Habito.fromMap(map)).toList();

    List<ProgressoData> progressoCalculado = [];

    for (var habito in habitos) {
      if (habito.id != null && habito.data_inicio != null) {
        final inicio = DateTime.parse(habito.data_inicio!);
        final fim = habito.data_termino != null
            ? DateTime.parse(habito.data_termino!)
            : inicio;
        final metaDias = fim.difference(inicio).inDays + 1;

        final diasConcluidos =
            await DatabaseHelper.instance.getTotalConclusoes(habito.id!);

        progressoCalculado.add(ProgressoData(
          habito: habito,
          metaDias: metaDias,
          diasConcluidos: diasConcluidos,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _listaDeProgresso = progressoCalculado;
        _isLoading = false;
      });
    }
  }

  // --- (Nenhuma mudança aqui) ---
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

  // --- AJUSTE NO MÉTODO build ---
  @override
  Widget build(BuildContext context) {
    final habitosEmProgresso =
        _listaDeProgresso.where((p) => p.diasConcluidos < p.metaDias).toList();
    final habitosConcluidos =
        _listaDeProgresso.where((p) => p.diasConcluidos >= p.metaDias).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      // --- AJUSTE FEITO AQUI ---
      appBar: AppBar(
        title: const Text('Progresso de Metas'),
        centerTitle: true,

      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _listaDeProgresso.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum hábito de período encontrado.",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, color: AppColors.graphite),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // O título que estava aqui foi removido (corretamente)
                      if (habitosEmProgresso.isNotEmpty) ...[
                        ...habitosEmProgresso.map((item) => ProgressoHabitoCard(
                              icon: _getIconForHabit(item.habito),
                              nome: item.habito.nome,
                              metaDias: item.metaDias,
                              diasConcluidos: item.diasConcluidos,
                            )),
                      ],

                      const SizedBox(height: 30),

                      // Subtítulo "Metas batidas:" (correto)
                      if (habitosConcluidos.isNotEmpty) ...[
                        const Text('Metas batidas:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.graphite)),
                        const SizedBox(height: 10),
                        ...habitosConcluidos.map((item) => ProgressoHabitoCard(
                              icon: _getIconForHabit(item.habito),
                              nome: item.habito.nome,
                              metaDias: item.metaDias,
                              diasConcluidos: item.diasConcluidos,
                            )),
                      ]
                    ],
                  ),
      ),
    );
  }
}