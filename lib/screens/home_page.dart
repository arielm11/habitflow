// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/data/models/registro_progresso_model.dart';
import 'package:habitflow/screens/add_habit_screen.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/habit_card.dart';

// --- MELHORIA: Adicionado import para a nova tela ---
import 'package:habitflow/screens/detalhes_habito_screen.dart'; 

/// Classe auxiliar que combina o Hábito com seu estado diário (progresso).
class HabitoComProgresso {
  final Habito habito;
  bool concluidoHoje;
  double progressoAtual; // Guarda o valor do progresso (ex: 7.0)

  HabitoComProgresso({
    required this.habito,
    required this.concluidoHoje,
    required this.progressoAtual,
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

  /// Retorna a data de hoje formatada como 'AAAA-MM-DD'.
  String get hojeFormatado {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  /// Carrega os hábitos ATIVOS para hoje e seus respectivos progressos.
  Future<void> _loadData() async {
    // --- MELHORIA 1: A busca no banco de dados agora filtra por data ---
    final habitsData = await DatabaseHelper.instance.queryActiveHabitsForDate(hojeFormatado);
    
    // O resto desta função continua como o original, trabalhando com a lista já filtrada.
    final registrosData =
        await DatabaseHelper.instance.queryRegistrosPorData(hojeFormatado);

    final allHabits = habitsData.map((map) => Habito.fromMap(map)).toList();

    final progressMap = {
      for (var registro in registrosData)
        registro['habitoId']: RegistroProgresso.fromMap(registro)
    };

    if (!mounted) return;

    setState(() {
      _habitosComProgresso = allHabits.map((habito) {
        final registro = progressMap[habito.id];
        return HabitoComProgresso(
          habito: habito,
          concluidoHoje: registro != null,
          progressoAtual: registro?.progressoAtual ?? 0.0,
        );
      }).toList();
      _isLoading = false;
    });
  }

  /// Lida com a mudança do checkbox para hábitos 'Feito/Não Feito'.
  Future<void> _onCheckboxChanged(
      bool? newValue, HabitoComProgresso item) async {
    if (item.habito.id == null) return;

    if (newValue == true) {
      await DatabaseHelper.instance.addProgress(item.habito.id!, 1.0);
    } else {
      await DatabaseHelper.instance
          .deleteRegistro(item.habito.id!, hojeFormatado);
    }
    _loadData();
  }

  /// Abre a tela para adicionar um novo hábito.
  void _navigateToAddHabit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    setState(() { _isLoading = true; });
    _loadData();
  }

  /// Abre a tela para editar um hábito existente.
  void _navigateToEditHabit(Habito habito) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(habito: habito),
      ),
    );
    setState(() { _isLoading = true; });
    _loadData();
  }
  
  /// Mostra um diálogo de confirmação para excluir um hábito.
  Future<bool> _confirmDeleteHabit(Habito habito) async {
    if (habito.id == null) return false;

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

    if (shouldDelete == true) {
      await DatabaseHelper.instance.deleteHabit(habito.id!);
      setState(() {
        _habitosComProgresso
            ?.removeWhere((item) => item.habito.id == habito.id);
      });
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
  
  /// Mostra um pop-up para o usuário digitar e adicionar um valor ao progresso.
  Future<void> _showAddProgressDialog(Habito habito) async {
    final formKey = GlobalKey<FormState>();
    final progressController = TextEditingController();

    final valorAdicionado = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Progresso para "${habito.nome}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: progressController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor a adicionar'),
              validator: (value) {
                if (value == null || value.isEmpty) { return 'Por favor, insira um valor.'; }
                if (double.tryParse(value.replaceAll(',', '.')) == null) { return 'Por favor, insira um número válido.'; }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final valor = double.parse(progressController.text.replaceAll(',', '.'));
                  Navigator.of(context).pop(valor);
                }
              },
            ),
          ],
        );
      },
    );

    if (valorAdicionado != null && valorAdicionado > 0 && habito.id != null) {
      await DatabaseHelper.instance.addProgress(habito.id!, valorAdicionado);
      _loadData();
    }
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
                    "Nenhum hábito ativo para hoje.\nClique no '+' para adicionar um!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.graphite),
                  ),
                )
              : ListView.builder(
                  itemCount: _habitosComProgresso!.length,
                  itemBuilder: (context, index) {
                    
                    final item = _habitosComProgresso![index];
                    
                    final bool isNumeric = item.habito.tipoMeta != 'Feito/Não Feito';
                    final metaTarget = isNumeric ? (double.tryParse(item.habito.metaValor?.split(' ').first.replaceAll(',', '.') ?? '1.0') ?? 1.0) : 1.0;
                    final bool goalMet = isNumeric ? (item.progressoAtual >= metaTarget) : item.concluidoHoje;
                    
                    final Color cardColor = goalMet ? AppColors.seaGreen.withOpacity(0.1) : Colors.white;
                    final BorderSide borderSide = goalMet ? BorderSide(color: AppColors.seaGreen, width: 1.5) : BorderSide.none;

                    // --- MELHORIA 2: Adicionado GestureDetector para Toque Longo ---
                    return GestureDetector(
                      onLongPress: () {
                        if (item.habito.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesHabitoScreen(
                                habitoId: item.habito.id!,
                              ),
                            ),
                            // Recarrega os dados ao voltar da tela de detalhes
                          ).then((_) => _loadData()); 
                        }
                      },
                      child: Dismissible(
                        key: Key(item.habito.id.toString()),
                        background: Container(
                          color: AppColors.seaGreen,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Row(children: [ Icon(Icons.edit, color: Colors.white), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                        ),
                        secondaryBackground: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [ Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete, color: Colors.white) ]),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _navigateToEditHabit(item.habito);
                            return false;
                          } else {
                            return await _confirmDeleteHabit(item.habito);
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: borderSide,
                          ),
                          child: HabitCard(
                            habito: item.habito,
                            isCompleted: item.concluidoHoje,
                            progress: item.progressoAtual,
                            onCheckboxChanged: (newValue) => _onCheckboxChanged(newValue, item),
                            onTap: () {
                              if (item.habito.tipoMeta != 'Feito/Não Feito') {
                                _showAddProgressDialog(item.habito);
                              }
                            },
                          ),
                        ),
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