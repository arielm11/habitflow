import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/data/models/registro_progresso_model.dart';
import 'package:habitflow/screens/add_habit_screen.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/habit_card.dart';

// Classe auxiliar
class HabitoComProgresso {
  final Habito habito;
  bool concluidoHoje;

  HabitoComProgresso({
    required this.habito,
    required this.concluidoHoje,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HabitoComProgresso>? _habitosComProgresso;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get hojeFormatado {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  Future<void> _loadData() async {
    // Busca os dados do banco
    final habitsData = await DatabaseHelper.instance.queryAllHabits();
    final registrosData =
        await DatabaseHelper.instance.queryRegistrosPorData(hojeFormatado);
    //Converte para map
    final allHabits = habitsData.map((map) => Habito.fromMap(map)).toList();
    final completedTodayIds =
        registrosData.map((map) => map['habitoId'] as int).toSet();

    // Atualiza o estado da tela com os dados carregados
    setState(() {
      _habitosComProgresso = allHabits.map((habito) {
        return HabitoComProgresso(
          habito: habito,
          concluidoHoje: completedTodayIds.contains(habito.id),
        );
      }).toList();
      _isLoading = false; // Terminou de carregar
    });
  }

  // Função ckeckbox -> clicado
  Future<void> _onCheckboxChanged(
      bool? newValue, HabitoComProgresso item) async {
    if (item.habito.id == null) return;

    setState(() {
      item.concluidoHoje = newValue ?? false;
    });

    if (newValue == true) {
      // Se marcou -> insere novo registro
      final registro =
          RegistroProgresso(habitoId: item.habito.id!, data: DateTime.now());
      await DatabaseHelper.instance.insertRegistro(registro.toMap());
    } else {
      // Se desmarcou -> deleta o registro
      await DatabaseHelper.instance
          .deleteRegistro(item.habito.id!, hojeFormatado);
    }
  }

  void _navigateToAddHabit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    setState(() {
      _isLoading = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Hábitos de Hoje'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habitosComProgresso == null || _habitosComProgresso!.isEmpty
              ? const Center(
                  child: Text(
                    "Você ainda não tem hábitos.\nClique no '+' para adicionar o primeiro!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.graphite),
                  ),
                )
              : ListView.builder(
                  itemCount: _habitosComProgresso!.length,
                  itemBuilder: (context, index) {
                    final item = _habitosComProgresso![index];
                    return HabitCard(
                      habitName: item.habito.nome,
                      description: item.habito.descricao,
                      icon: Icons.check_circle_outline,
                      isCompleted: item.concluidoHoje,
                      onChanged: (newValue) =>
                          _onCheckboxChanged(newValue, item),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        tooltip: 'Adicionar Hábito',
        child: const Icon(Icons.add),
      ),
    );
  }
}
