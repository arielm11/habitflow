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
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ProgressoGeralScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CORREÇÃO APLICADA AQUI ---
      // Trocamos o IndexedStack para forçar a reconstrução da tela
      // a cada troca de aba, garantindo que os dados do Provider
      // sejam sempre os mais recentes.
      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.graphite.withOpacity(0.7),
        onTap: _onItemTapped,
        backgroundColor: AppColors.background,
        elevation: 8.0,
      ),
    );
  }
}