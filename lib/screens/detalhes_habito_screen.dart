// lib/screens/detalhes_habito_screen.dart

import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/utils/app_colors.dart';

class DetalhesHabitoScreen extends StatefulWidget {
  final int habitoId;

  const DetalhesHabitoScreen({Key? key, required this.habitoId}) : super(key: key);

  @override
  State<DetalhesHabitoScreen> createState() => _DetalhesHabitoScreenState();
}

class _DetalhesHabitoScreenState extends State<DetalhesHabitoScreen> {
  // Este Future vai guardar o resultado da nossa busca no banco de dados.
  late Future<Map<String, dynamic>> _dadosProgressoFuture;

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, chamamos a função que busca os dados no DatabaseHelper.
    _dadosProgressoFuture = DatabaseHelper.instance.getDadosProgresso(widget.habitoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Hábito'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dadosProgressoFuture,
        builder: (context, snapshot) {
          // Enquanto os dados estão carregando, mostramos um indicador de progresso.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se ocorrer um erro na busca.
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar detalhes: ${snapshot.error}'));
          }

          // Se os dados chegarem com sucesso.
          if (snapshot.hasData) {
            final dados = snapshot.data!;
            final Habito habito = dados['habito'];
            final int concluidos = dados['concluidos'];
            final int decorridos = dados['decorridos'];

            // Constrói a tela com as informações
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habito.nome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.graphite,
                    ),
                  ),
                  if (habito.descricao != null && habito.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      habito.descricao!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.graphite.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  // Card de Progresso
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'PROGRESSO TOTAL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.graphite,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$concluidos',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.teal,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / $decorridos',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.graphite.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'dias concluídos',
                             style: TextStyle(
                                fontSize: 16,
                                color: AppColors.graphite.withOpacity(0.8),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Informações do Período
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.graphite),
                      const SizedBox(width: 8),
                      Text(
                        'Período: ${habito.data_inicio} até ${habito.data_termino ?? 'sem data final'}',
                         style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }

          // Caso não haja dados.
          return const Center(child: Text('Nenhum detalhe encontrado.'));
        },
      ),
    );
  }
}