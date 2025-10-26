// lib/data/providers/habito_provider.dart
import 'package:flutter/material.dart';
import 'package:habitflow/data/database/database_helper.dart';
import 'package:habitflow/data/models/habito_model.dart';
import 'package:habitflow/data/models/progresso_data.model.dart'; // A classe que acabámos de mover
import 'package:habitflow/data/models/habito_model.dart';

// A classe HabitoComProgresso permanece a mesma
class HabitoComProgresso {
  final Habito habito;
  bool concluidoHoje;
  double progressoAtual;
  HabitoComProgresso({required this.habito, this.concluidoHoje = false, this.progressoAtual = 0.0});
}

class HabitoProvider with ChangeNotifier {

  // Dentro da classe HabitoProvider

  // ... (as tuas variáveis existentes, ex: _habitosDoDia, _isLoading) ...

  // NOVAS VARIÁVEIS DE ESTADO PARA A TELA DE PROGRESSO
  bool _isLoadingProgresso = false;
  List<ProgressoData> _habitosComPeriodo = [];
  List<ProgressoData> _habitosContinuos = [];
  List<PerformanceDia> _performanceSemanal = [];
  
  // (Provavelmente já tens esta linha, se não, adiciona-a)
  final dbHelper = DatabaseHelper.instance; 

  // NOVOS GETTERS
  bool get isLoadingProgresso => _isLoadingProgresso;
  List<ProgressoData> get habitosComPeriodo => _habitosComPeriodo;
  List<ProgressoData> get habitosContinuos => _habitosContinuos;
  List<PerformanceDia> get performanceSemanal => _performanceSemanal;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<HabitoComProgresso> _habitosDoDia = [];
  List<Habito> _habitosDePeriodo = [];
  Map<int, int> _progressoTotal = {};
  bool _isLoading = true;

  List<HabitoComProgresso> get habitosDoDia => _habitosDoDia;
  List<Habito> get habitosDePeriodo => _habitosDePeriodo;
  int getProgressoTotal(int habitoId) => _progressoTotal[habitoId] ?? 0;
  bool get isLoading => _isLoading;

// Dentro da classe HabitoProvider

// Dentro da classe HabitoProvider

  /// Carrega TODOS os dados para a Tela de Progresso Geral
  Future<void> carregarDadosProgresso() async {
    // Evita recargas múltiplas se já estiver a carregar
    if (_isLoadingProgresso) return;

    _isLoadingProgresso = true;
    notifyListeners();

    // --- TAREFA 5: Lógica de 'loadData' movida para o Provider ---
    
    // 1. Busca os hábitos (usando a tua função que já funciona)
    final habitosMap = await dbHelper.getHabitosDePeriodo();
    final habitos = habitosMap.map((map) => Habito.fromMap(map)).toList();

    List<ProgressoData> periodosCalculados = [];
    List<ProgressoData> continuosCalculados = [];

    for (var habito in habitos) {
      if (habito.id != null) {
        final diasConcluidos = await dbHelper.getTotalConclusoes(habito.id!);

        if (habito.data_termino != null) { // Hábito com Período
          final inicio = DateTime.parse(habito.data_inicio!);
          final fim = DateTime.parse(habito.data_termino!);
          final metaDias = fim.difference(inicio).inDays + 1;

          periodosCalculados.add(ProgressoData(
            habito: habito,
            metaDias: metaDias,
            diasConcluidos: diasConcluidos,
          ));
        } else { // Hábito Contínuo
          continuosCalculados.add(ProgressoData(
            habito: habito,
            metaDias: 0, 
            diasConcluidos: diasConcluidos,
          ));
        }
      }
    }
    _habitosComPeriodo = periodosCalculados;
    _habitosContinuos = continuosCalculados;
    
    // --- TAREFA 4: Lógica do Gráfico de Performance ---
    List<PerformanceDia> performanceCalculada = [];
    final hoje = DateTime.now();

    for (int i = 6; i >= 0; i--) { // Loop dos últimos 7 dias
      final data = hoje.subtract(Duration(days: i));
      final dataStr = data.toIso8601String().substring(0, 10);
      
      // 1. Encontra hábitos que estavam ativos nesse dia
      final habitosAtivosMap = await dbHelper.queryActiveHabitsForDate(dataStr);
      final habitosAtivos = habitosAtivosMap.map((map) => Habito.fromMap(map)).toList();
      
      // 2. Encontra os registos de progresso feitos nesse dia
      final registrosMap = await dbHelper.queryRegistrosPorData(dataStr);

      if (habitosAtivos.isEmpty) {
        // Se não havia hábitos ativos, a taxa é 0
        performanceCalculada.add(PerformanceDia(
          diaSemana: _getDiaSemana(data), taxaConclusao: 0.0
        ));
        continue;
      }

      int concluidos = 0;
      // 3. Compara os hábitos ativos com os registos
      for (var habito in habitosAtivos) {
        final registro = registrosMap.firstWhere(
          (r) => r['habitoId'] == habito.id,
          orElse: () => {'progressoAtual': 0.0} // Se não há registo, progresso é 0
        );
        final progresso = (registro['progressoAtual'] as num).toDouble();
        
        if (_isHabitoCompleto(habito, progresso)) {
          concluidos++;
        }
      }
      
      // 4. Calcula a taxa de sucesso do dia
      double taxa = (habitosAtivos.isEmpty) ? 0.0 : (concluidos / habitosAtivos.length);
      performanceCalculada.add(PerformanceDia(
        diaSemana: _getDiaSemana(data), taxaConclusao: taxa
      ));
    }
    _performanceSemanal = performanceCalculada;

    // --- Finaliza ---
    _isLoadingProgresso = false;
    notifyListeners();
  }

  /// Função auxiliar para verificar se um hábito foi completo
  bool _isHabitoCompleto(Habito habito, double progresso) {
    if (habito.tipoMeta == 'Feito/Não Feito') {
      return progresso >= 1.0;
    } else if (habito.tipoMeta == 'Meta Numérica' || habito.tipoMeta == 'Duração') {
      final metaValorStr = habito.metaValor?.split(' ').first.replaceAll(',', '.') ?? '1.0';
      final metaValor = double.tryParse(metaValorStr) ?? 1.0;
      return progresso >= metaValor;
    }
    return false;
  }
  
  /// Função auxiliar para formatar os dias da semana
  String _getDiaSemana(DateTime data) {
    // (weekday: 1=Seg, 7=Dom)
    // Ajustado para o padrão do Dart onde 7=Domingo
    const dias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return dias[data.weekday % 7];
  }


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
/// Modelo de dados para o gráfico de performance
class PerformanceDia {
  final String diaSemana; // Ex: "Seg"
  final double taxaConclusao; // 0.0 a 1.0

  PerformanceDia({required this.diaSemana, required this.taxaConclusao});
}