import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/utils/app_colors.dart';

class AddHabitScreen extends StatefulWidget {
  final Habito? habito;

  const AddHabitScreen({super.key, this.habito});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variável para guardar o tipo de meta selecionado.
  // Começa com 'Feito/Não Feito' como padrão.
  String _selectedGoalType = 'Feito/Não Feito';

  // Variável para verificar se está editando um hábito ou não
  bool get _isEditing => widget.habito != null;

  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.habito!.nome;
      _descriptionController.text = widget.habito!.descricao ?? '';
      _selectedGoalType = widget.habito!.tipoMeta;
    }
  }

  // Função para salvar o hábito no banco de dados.
  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final updatedHabit = Habito(
          id: widget.habito!.id,
          nome: _nameController.text,
          descricao: _descriptionController.text,
          tipoMeta: _selectedGoalType,
          ativo: widget.habito!.ativo,
        );
        await DatabaseHelper.instance.updateHabit(updatedHabit.toMap());
      } else {
        final newHabit = Habito(
          nome: _nameController.text,
          descricao: _descriptionController.text,
          tipoMeta: _selectedGoalType,
          ativo: true, // Todo novo hábito começa como ativo.
        );
        await DatabaseHelper.instance.insertHabit(newHabit.toMap());
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Hábito' : 'Adicionar Novo Hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),

                // --- CAMPO DE TEXTO PARA A DESCRIÇÃO DO HABITO ---
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opicional)',
                    hintText: 'Beber aguá 2L de Água por dia',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 32),

                // --- BOTÃO DE SALVAR ---
                ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      Text(_isEditing ? 'Salvar Alterações' : 'Salvar Hábito'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
