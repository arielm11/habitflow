// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/data/providers/habito_provider.dart';
import 'package:habitflow/screens/add_habit_screen.dart';
import 'package:habitflow/screens/detalhes_habito_screen.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/widgets/habit_card.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // --- Nenhuma alteração nesta seção ---
  void _navigateToAddHabit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    context.read<HabitoProvider>().carregarTodosOsDados();
  }

  void _navigateToEditHabit(BuildContext context, Habito habito) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddHabitScreen(habito: habito)),
    );
    context.read<HabitoProvider>().carregarTodosOsDados();
  }

  Future<bool> _confirmDeleteHabit(BuildContext context, Habito habito) async {
    if (habito.id == null) return false;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Você tem certeza que deseja excluir o hábito "${habito.nome}"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await context.read<HabitoProvider>().deletarHabito(habito.id!);

      if (context.mounted) {
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
  // --- Fim da seção sem alterações ---

  /// Mostra um pop-up para o usuário ATUALIZAR o progresso.
  Future<void> _showUpdateProgressDialog(
    BuildContext context,
    Habito habito,
    double progressoAtual, // 1. Recebe o progresso atual
  ) async {
    final formKey = GlobalKey<FormState>();
    final progressController = TextEditingController();

    // 2. Pré-preenche o campo com o valor que já existe
    progressController.text =
        progressoAtual.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

    final novoValor = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Atualizar Progresso para "${habito.nome}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: progressController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Novo valor'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor.';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Por favor, insira um número válido.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton(
              child: const Text('Atualizar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final valor = double.parse(
                      progressController.text.replaceAll(',', '.'));
                  Navigator.of(dialogContext).pop(valor);
                }
              },
            ),
          ],
        );
      },
    );

    //
    // --- AJUSTE FEITO AQUI ---
    //
    // 7. LÓGICA DE ATUALIZAÇÃO
    // Comparamos o novoValor (o que foi digitado) com o progressoAtual
    // e SÓ atualizamos se o valor for diferente.
    if (novoValor != null && novoValor != progressoAtual && habito.id != null) {
      
      // Pega o provider uma vez para evitar múltiplas chamadas 'read'
      final provider = context.read<HabitoProvider>();

      // 8. SIMULA A ATUALIZAÇÃO usando os métodos que você já tem:

      // Primeiro, zera o progresso atual do dia
      await provider.deletarProgressoDiario(habito.id!);

      // Segundo, registra o novo valor (a menos que o novo valor seja 0,
      // pois nesse caso só queríamos zerar, o que já foi feito)
      if (novoValor > 0) {
        await provider.registrarProgressoDiario(habito.id!, novoValor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Conecta à fonte de dados central: o HabitoProvider.
    final provider = context.watch<HabitoProvider>();
    final habitosDoDia = provider.habitosDoDia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Hábitos de Hoje'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitosDoDia.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum hábito ativo para hoje.\nClique no '+' para adicionar um!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.graphite),
                  ),
                )
              : ListView.builder(
                  itemCount: habitosDoDia.length,
                  itemBuilder: (context, index) {
                    final item = habitosDoDia[index];

                    // --- Nenhuma alteração nesta seção de lógica ---
                    final bool isNumeric =
                        item.habito.tipoMeta != 'Feito/Não Feito';
                    final metaTarget = isNumeric
                        ? (double.tryParse(item.habito.metaValor
                                ?.split(' ')
                                .first
                                .replaceAll(',', '.') ??
                            '1.0') ??
                        1.0)
                        : 1.0;
                    final bool goalMet = isNumeric
                        ? (item.progressoAtual >= metaTarget)
                        : item.concluidoHoje;
                    final Color cardColor = goalMet
                        ? AppColors.seaGreen.withOpacity(0.1)
                        : Colors.white;
                    final BorderSide borderSide = goalMet
                        ? BorderSide(color: AppColors.seaGreen, width: 1.5)
                        : BorderSide.none;
                    // --- Fim da seção sem alterações ---

                    return GestureDetector(
                      onLongPress: () {
                        // ... (sem alterações)
                        if (item.habito.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetalhesHabitoScreen(
                                        habitoId: item.habito.id!)),
                          ).then((_) =>
                              context.read<HabitoProvider>().carregarTodosOsDados());
                        }
                      },
                      child: Dismissible(
                        key: Key(item.habito.id.toString()),
                        // ... (backgrounds sem alterações) ...
                        background: Container(
                          color: AppColors.seaGreen,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Row(children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Editar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ]),
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
                                Icon(Icons.delete, color: Colors.white)
                              ]),
                        ),
                        confirmDismiss: (direction) async {
                          // ... (sem alterações)
                          if (direction == DismissDirection.startToEnd) {
                            _navigateToEditHabit(context, item.habito);
                            return false;
                          } else {
                            return await _confirmDeleteHabit(
                                context, item.habito);
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                            onCheckboxChanged: (newValue) {
                              // ... (sem alterações na lógica do checkbox)
                              if (item.habito.id == null) return;
                              if (newValue == true) {
                                context
                                    .read<HabitoProvider>()
                                    .registrarProgressoDiario(
                                        item.habito.id!, 1.0);
                              } else {
                                context
                                    .read<HabitoProvider>()
                                    .deletarProgressoDiario(item.habito.id!);
                              }
                            },
                            //
                            // --- Nenhuma alteração aqui, já estava certo ---
                            //
                            onTap: () {
                              if (item.habito.tipoMeta != 'Feito/Não Feito') {
                                // Chama a nova função e passa o valor atual
                                _showUpdateProgressDialog(
                                  context,
                                  item.habito,
                                  item.progressoAtual, // Passa o valor!
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}