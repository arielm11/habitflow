// lib/data/providers/habito_provider.dart
import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';

// A classe HabitoComProgresso permanece a mesma
class HabitoComProgresso {
  final Habito habito;
  bool concluidoHoje;
  double progressoAtual;
  HabitoComProgresso({required this.habito, this.concluidoHoje = false, this.progressoAtual = 0.0});
}

class HabitoProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<HabitoComProgresso> _habitosDoDia = [];
  List<Habito> _habitosDePeriodo = [];
  Map<int, int> _progressoTotal = {};
  bool _isLoading = true;

  List<HabitoComProgresso> get habitosDoDia => _habitosDoDia;
  List<Habito> get habitosDePeriodo => _habitosDePeriodo;
  int getProgressoTotal(int habitoId) => _progressoTotal[habitoId] ?? 0;
  bool get isLoading => _isLoading;

  HabitoProvider() {
    carregarTodosOsDados();
  }
  
  String get hojeFormatado => DateTime.now().toIso8601String().substring(0, 10);

  // Esta função continua sendo nossa carga inicial e "resgate" de segurança
  Future<void> carregarTodosOsDados() async {
    _isLoading = true;
    notifyListeners();

    // Lógica de carregamento principal (sem alterações)
    final habitsData = await _dbHelper.queryActiveHabitsForDate(hojeFormatado);
    final registrosData = await _dbHelper.queryRegistrosPorData(hojeFormatado);
    final allHabits = habitsData.map((map) => Habito.fromMap(map)).toList();
    final progressMap = { for (var r in registrosData) r['habitoId']: r['progressoAtual'] as double };
    _habitosDoDia = allHabits.map((h) => HabitoComProgresso(
      habito: h,
      concluidoHoje: progressMap.containsKey(h.id),
      progressoAtual: progressMap[h.id] ?? 0.0,
    )).toList();

    final habitosPeriodoData = await _dbHelper.getHabitosDePeriodo();
    _habitosDePeriodo = habitosPeriodoData.map((map) => Habito.fromMap(map)).toList();
    _progressoTotal.clear();
    for (var habito in _habitosDePeriodo) {
      if (habito.id != null) {
        _progressoTotal[habito.id!] = await _dbHelper.getTotalConclusoes(habito.id!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- MELHORIA PRINCIPAL ABAIXO ---

  /// Registra o progresso de um hábito de forma otimista.
  Future<void> registrarProgressoDiario(int habitoId, double valor) async {
    // 1. Atualiza o banco de dados em segundo plano
    _dbHelper.addProgress(habitoId, valor);

    // 2. Atualiza o estado local (em memória)
    final indexDia = _habitosDoDia.indexWhere((h) => h.habito.id == habitoId);
    if (indexDia != -1) {
      _habitosDoDia[indexDia].progressoAtual += valor;
      // Para hábitos 'Feito/Não feito', marcar como concluído
      if (valor == 1.0 && _habitosDoDia[indexDia].habito.tipoMeta == 'Feito/Não Feito') {
        _habitosDoDia[indexDia].concluidoHoje = true;
      }
    }
    
    // Atualiza também o contador da tela de progresso
    if (_progressoTotal.containsKey(habitoId)) {
      _progressoTotal[habitoId] = _progressoTotal[habitoId]! + 1;
    } else {
        // Se não existia, pode ser o primeiro registro, então buscamos do DB.
        _progressoTotal[habitoId] = await _dbHelper.getTotalConclusoes(habitoId);
    }
    
    // 3. Notifica a UI IMEDIATAMENTE, sem loading.
    notifyListeners();
  }

  /// Deleta o registro de progresso de um hábito de forma otimista.
  Future<void> deletarProgressoDiario(int habitoId) async {
    // 1. Atualiza o banco de dados em segundo plano
    _dbHelper.deleteRegistro(habitoId, hojeFormatado);
    
    // 2. Atualiza o estado local (em memória)
    final indexDia = _habitosDoDia.indexWhere((h) => h.habito.id == habitoId);
    if (indexDia != -1) {
       _habitosDoDia[indexDia].progressoAtual = 0; // Zera o progresso do dia
      _habitosDoDia[indexDia].concluidoHoje = false;
    }
    
    // Atualiza também o contador da tela de progresso
    if (_progressoTotal.containsKey(habitoId) && _progressoTotal[habitoId]! > 0) {
      _progressoTotal[habitoId] = _progressoTotal[habitoId]! - 1;
    }

    // 3. Notifica a UI IMEDIATAMENTE, sem loading.
    notifyListeners();
  }
  
  /// Deleta um hábito e recarrega os dados (ação mais pesada)
  Future<void> deletarHabito(int habitoId) async {
    await _dbHelper.deleteHabit(habitoId);
    // Como deletar um hábito é uma grande mudança, aqui um reload completo faz sentido.
    await carregarTodosOsDados();
  }
}