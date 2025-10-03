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
  final _metaValorController = TextEditingController();
  final _metaUnidadecontroller = TextEditingController();

  String _selectedGoalType = 'Feito/Não Feito';
  bool get _isEditing => widget.habito != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.habito!.nome;
      _descriptionController.text = widget.habito!.descricao ?? '';
      _selectedGoalType = widget.habito!.tipoMeta;
      final metaValorExistente = widget.habito!.metaValor;
      if (metaValorExistente != null && metaValorExistente.isNotEmpty) {
        final parts = metaValorExistente.split(' ');
        if (parts.isNotEmpty) {
          _metaValorController.text = parts.first;
        }
        if (parts.length > 1) {
          _metaUnidadecontroller.text = parts.sublist(1).join(' ');
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _metaValorController.dispose();
    _metaUnidadecontroller.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      // --- CORREÇÃO: Lógica para preparar o metaValor antes de salvar ---
      String? metaValorFinal;
      if (_selectedGoalType == 'Meta Numérica' || _selectedGoalType == 'Duração') {
        final valor = _metaValorController.text.trim();
        final unidade = _metaUnidadecontroller.text.trim();
        if (valor.isNotEmpty && unidade.isNotEmpty) {
          metaValorFinal = '$valor $unidade';
        }
      }
      // --- FIM DA CORREÇÃO ---

      if (_isEditing) {
        final updatedHabit = Habito(
          id: widget.habito!.id,
          nome: _nameController.text,
          descricao: _descriptionController.text,
          tipoMeta: _selectedGoalType,
          metaValor: metaValorFinal, // PASSANDO O VALOR AQUI
          ativo: widget.habito!.ativo,
        );
        await DatabaseHelper.instance.updateHabit(updatedHabit.toMap());
      } else {
        final newHabit = Habito(
          nome: _nameController.text,
          descricao: _descriptionController.text,
          tipoMeta: _selectedGoalType,
          metaValor: metaValorFinal, // E AQUI TAMBÉM
          ativo: true,
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
                const Text('Qual o tipo de meta?', style: TextStyle(fontSize: 16)),
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
                const SizedBox(height: 16),

                // --- PARTE FALTANTE: Adicionar os campos condicionais para a meta ---
                Visibility(
                  visible: _selectedGoalType == 'Meta Numérica' || _selectedGoalType == 'Duração',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _metaValorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor da Meta',
                          hintText: 'Ex: 10, 2, 500',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_selectedGoalType != 'Feito/Não Feito') {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um valor.';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _metaUnidadecontroller,
                        decoration: const InputDecoration(
                          labelText: 'Unidade da Meta',
                          hintText: 'Ex: páginas, litros, minutos',
                          border: OutlineInputBorder(),
                        ),
                         validator: (value) {
                          if (_selectedGoalType != 'Feito/Não Feito') {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira uma unidade.';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // --- FIM DA PARTE FALTANTE ---

                const SizedBox(height: 32),
                // --- BOTÃO DE SALVAR ---
                ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isEditing ? 'Salvar Alterações' : 'Salvar Hábito'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}