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
    if (!mounted) return;

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

  // --- FUNÇÃO PARA ADICIONAR UM HÁBITO ---
  void _navigateToAddHabit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    setState(() {
      _isLoading = true;
    });
    _loadData();
  }

  // --- FUNÇÃO PARA EDITAR UM HÁBITO ---
  void _navigateToEditHabit(Habito habito) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(habito: habito),
      ),
    );

    setState(() {
      _isLoading = true;
    });
    _loadData();
  }

  // --- FUNÇÃO PARA EXCLUIR UM HÁBITO ---
  Future<bool> _confirmDeleteHabit(Habito habito) async {
    if (habito.id == null) return false;

    // Diálogo de confirmação
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Você tem certeza que deseja excluir o hábito "${habito.nome}"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Se o usuário confirmou, procede com a exclusão
    if (shouldDelete == true) {
      await DatabaseHelper.instance.deleteHabit(habito.id!);

      // Atualiza a lista localmente para uma resposta visual instantânea
      setState(() {
        _habitosComProgresso
            ?.removeWhere((item) => item.habito.id == habito.id);
      });

      // Mostra uma confirmação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hábito "${habito.nome}" excluído.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return true;
    }
    return false;
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
                    return Dismissible(
                      key: Key(item.habito.id.toString()),
                      background: Container(
                        color: AppColors.seaGreen,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Editar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Excluir',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.delete, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _navigateToEditHabit(item.habito);
                          return false;
                        } else {
                          return await _confirmDeleteHabit(item.habito);
                        }
                      },
                      child: HabitCard(
                        habitName: item.habito.nome,
                        description: item.habito.descricao,
                        icon: Icons.check_circle_outline,
                        isCompleted: item.concluidoHoje,
                        onChanged: (newValue) =>
                            _onCheckboxChanged(newValue, item),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}
