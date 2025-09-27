import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/habit_card.dart'; // Importando nosso novo widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _habits = [
    {'name': 'Beber 2L de Água', 'icon': Icons.water_drop, 'isCompleted': true},
    {'name': 'Ler 10 páginas', 'icon': Icons.book, 'isCompleted': false},
    {
      'name': 'Meditar por 5 min',
      'icon': Icons.self_improvement,
      'isCompleted': false
    },
  ];

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
            child: ListView.builder(
              itemCount: _habits.length, // O número de itens na lista
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return HabitCard(
                  habitName: habit['name'],
                  icon: habit['icon'],
                  isCompleted: habit['isCompleted'],
                  onChanged: (newValue) {
                    // setState atualiza a tela quando um valor muda.
                    setState(() {
                      _habits[index]['isCompleted'] = newValue ?? false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para adicionar um novo hábito
        },
        tooltip: 'Adicionar Hábito',
        child: const Icon(Icons.add),
      ),
    );
  }
}
