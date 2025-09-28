import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/screens/add_habit_screen.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/habit_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Habito>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    setState(() {
      _habitsFuture = DatabaseHelper.instance.queryAllHabits().then((maps) {
        return maps.map((map) => Habito.fromMap(map)).toList();
      });
    });
  }

  void _navigateToAddHabit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Hábitos de Hoje'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO COM A DATA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Quinta-feira, 25 de Setembro', // Data de exemplo
              style: TextStyle(
                color: AppColors.graphite.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- LISTA DE HÁBITOS ---
          Expanded(
            // USANDO O FUTUREBUILDER:
            // Este widget constrói a interface com base no estado da nossa 'Future'.
            child: FutureBuilder<List<Habito>>(
              future: _habitsFuture,
              builder: (context, snapshot) {
                // 1. Enquanto os dados estão carregando:
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Se ocorrer um erro:
                else if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }
                // 3. Se os dados chegarem com sucesso, mas a lista estiver vazia:
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Você ainda não tem hábitos.\nClique no '+' para adicionar o primeiro!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.graphite),
                    ),
                  );
                }
                // 4. Se os dados chegarem com sucesso e a lista não estiver vazia:
                else {
                  final habits = snapshot.data!;
                  return ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitCard(
                        habitName: habit.nome,
                        // Ícone de exemplo por enquanto
                        icon: Icons.check_circle_outline,
                        // Estado do checkbox de exemplo por enquanto
                        isCompleted: false,
                        onChanged: (newValue) {
                          // Lógica para atualizar o progresso virá aqui.
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit, // Chama a nova função de navegação
        tooltip: 'Adicionar Hábito',
        child: const Icon(Icons.add),
      ),
    );
  }
}
