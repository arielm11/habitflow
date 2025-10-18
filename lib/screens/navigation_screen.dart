// lib/screens/navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:habitflow/screens/home_page.dart';
import 'package:habitflow/screens/progresso_geral_screen.dart';
import 'package:habitflow/utils/app_colors.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Guarda o índice (0 ou 1) da aba que está selecionada.
  int _selectedIndex = 0;

  // Lista das telas que o menu irá controlar.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Aba 0
    ProgressoGeralScreen(), // Aba 1
  ];

  // Função chamada quando o usuário toca em um item do menu.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo agora usa um IndexedStack.
      // Isso é uma melhoria importante: ele mantém o estado das telas
      // ao trocar de aba. Por exemplo, se o usuário rolar a lista na
      // HomePage, ao trocar de aba e voltar, a rolagem continuará lá.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // Aqui criamos o menu inferior.
      bottomNavigationBar: BottomNavigationBar(
        // Itens do menu
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Hoje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
        ],
        currentIndex: _selectedIndex, // Qual aba está ativa
        selectedItemColor: AppColors.teal, // Cor da aba ativa
        unselectedItemColor:
            AppColors.graphite.withOpacity(0.7), // Cor das inativas
        onTap: _onItemTapped, // O que fazer ao tocar
        backgroundColor: AppColors.background,
        elevation: 8.0,
      ),
    );
  }
}
