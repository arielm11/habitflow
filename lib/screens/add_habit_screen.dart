// lib/screens/add_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/utils/app_colors.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  // Chave global para identificar e validar nosso formulário.
  final _formKey = GlobalKey<FormState>();
  // Controlador para o campo de texto do nome.
  final _nameController = TextEditingController();

  // Variável para guardar o tipo de meta selecionado.
  // Começa com 'Feito/Não Feito' como padrão.
  String _selectedGoalType = 'Feito/Não Feito';

  // Função para salvar o hábito no banco de dados.
  Future<void> _saveHabit() async {
    // Primeiro, validamos o formulário. Se não for válido, não fazemos nada.
    if (_formKey.currentState!.validate()) {
      // Criamos um novo objeto Habito com os dados do formulário.
      final newHabit = Habito(
        nome: _nameController.text,
        tipoMeta: _selectedGoalType,
        ativo: true, // Todo novo hábito começa como ativo.
      );

      // Usamos nosso DatabaseHelper para inserir o hábito.
      await DatabaseHelper.instance.insertHabit(newHabit.toMap());

      // Se o widget ainda estiver na "árvore" de widgets (ou seja, a tela ainda existe),
      // voltamos para a tela anterior.
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CAMPO DE TEXTO PARA O NOME DO HÁBITO ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hábito',
                  hintText: 'Ex: Beber água, Ler um livro',
                  border: OutlineInputBorder(),
                ),
                // Validador para garantir que o campo não está vazio.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o hábito.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- SELETOR PARA O TIPO DE META ---
              const Text('Qual o tipo de meta?',
                  style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: _selectedGoalType,
                isExpanded: true,
                items: <String>['Feito/Não Feito', 'Meta Numérica', 'Duração']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGoalType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // --- BOTÃO DE SALVAR ---
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar Hábito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
