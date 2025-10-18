// lib/screens/progresso_geral_screen.dart

import 'package:flutter/material.dart';
import 'package:habitflow/utils/app_colors.dart';

class ProgressoGeralScreen extends StatelessWidget {
  const ProgressoGeralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Progresso Geral'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Em breve: Gráficos e estatísticas!',
          style: TextStyle(fontSize: 18, color: AppColors.graphite),
        ),
      ),
    );
  }
}
