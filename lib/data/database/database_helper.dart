import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:habitflow/data/models/habito_model.dart'; // ADICIONADO IMPORT

class DatabaseHelper {
  static const _databaseName = 'habitflow.db';
  static const _databaseVersion = 5;

  static const tableHabitos = 'habitos';
  static const tableRegistros = 'registros_progresso';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHabitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        tipoMeta TEXT NOT NULL,
        metaValor TEXT,
        ativo INTEGER NOT NULL,
        data_inicio TEXT,
        dataTermino TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRegistros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitoId INTEGER NOT NULL,
        data TEXT NOT NULL,
        progressoAtual REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (habitoId) REFERENCES $tableHabitos (id) ON DELETE CASCADE,
        UNIQUE(habitoId, data)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableHabitos ADD COLUMN descricao TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $tableRegistros (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habitoId INTEGER NOT NULL,
          data TEXT NOT NULL,
          FOREIGN KEY (habitoId) REFERENCES $tableHabitos (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE $tableRegistros ADD COLUMN progressoAtual REAL NOT NULL DEFAULT 0');
      await db.execute(
          'CREATE UNIQUE INDEX idx_habito_data ON $tableRegistros(habitoId, data)');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tableHabitos ADD COLUMN data_inicio TEXT');
      await db.execute('ALTER TABLE $tableHabitos ADD COLUMN dataTermino TEXT');
    }
  }

  // --- MÉTODOS CRUD PARA HÁBITOS ---
  Future<List<Map<String, dynamic>>> queryAllHabits() async {
    Database db = await instance.database;
    return await db.query(tableHabitos, orderBy: "id DESC");
  }

  Future<List<Map<String, dynamic>>> queryActiveHabitsForDate(
      String data) async {
    Database db = await instance.database;
    return await db.query(tableHabitos,
        where: 'data_inicio <= ? AND (dataTermino IS NULL OR dataTermino >= ?)',
        whereArgs: [data, data],
        orderBy: "id DESC");
  }

  Future<int> insertHabit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableHabitos, row);
  }

  Future<int> updateHabit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(tableHabitos, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteHabit(int id) async {
    Database db = await instance.database;
    return await db.delete(tableHabitos, where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS CRUD PARA REGISTRO DE PROGRESSO ---
  Future<void> addProgress(int habitoId, double valorAdicionado) async {
    final db = await instance.database;
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    await db.rawInsert('''
      INSERT INTO registros_progresso (habitoId, data, progressoAtual)
      VALUES (?, ?, ?)
      ON CONFLICT(habitoId, data) DO UPDATE SET
      progressoAtual = progressoAtual + ?
    ''', [habitoId, hoje, valorAdicionado, valorAdicionado]);
  }

  Future<List<Map<String, dynamic>>> queryRegistrosPorData(String data) async {
    Database db = await instance.database;
    return await db.query(tableRegistros, where: 'data = ?', whereArgs: [data]);
  }

  Future<void> deleteRegistro(int habitoId, String data) async {
    Database db = await instance.database;
    await db.delete(tableRegistros,
        where: 'habitoId = ? AND data = ?', whereArgs: [habitoId, data]);
  }

  Future<void> insertRegistro(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(tableRegistros, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- NOVAS FUNÇÕES ADICIONADAS PARA A TELA DE DETALHES ---

  /// Busca um único hábito pelo seu ID.
  Future<Habito> getHabitoById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableHabitos,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habito.fromMap(maps.first);
    } else {
      throw Exception('ID $id não encontrado');
    }
  }

  /// Conta o total de dias que um hábito foi concluído.
  Future<int> getTotalConclusoes(int habitoId) async {
    final db = await instance.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableRegistros WHERE habitoId = ?',
      [habitoId],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Calcula quantos dias se passaram desde o início do hábito até hoje.
  int calcularDiasDecorridos(String dataInicioStr, String? dataTerminoStr) {
    final dataInicio = DateTime.parse(dataInicioStr);
    final hoje = DateTime.now();
    final hojeApenasData = DateTime(hoje.year, hoje.month, hoje.day);

    DateTime dataFinalConsiderada;
    if (dataTerminoStr == null ||
        dataTerminoStr.isEmpty ||
        DateTime.parse(dataTerminoStr).isAfter(hojeApenasData)) {
      dataFinalConsiderada = hojeApenasData;
    } else {
      dataFinalConsiderada = DateTime.parse(dataTerminoStr);
    }

    if (dataFinalConsiderada.isBefore(dataInicio)) {
      return 0;
    }

    return dataFinalConsiderada.difference(dataInicio).inDays + 1;
  }

  Future<List<Map<String, dynamic>>> getHabitosDePeriodo() async {
    Database db = await instance.database;
    // A condição 'data_inicio IS NOT NULL' filtra apenas os hábitos que nos interessam.
    return await db.query(tableHabitos,
        where: 'data_inicio IS NOT NULL AND data_inicio != ?',
        whereArgs: [''], // Garante que data_inicio não seja uma string vazia
        orderBy: "id DESC");
  }

  /// Orquestra a busca de todos os dados necessários para a tela de detalhes.
  Future<Map<String, dynamic>> getDadosProgresso(int habitoId) async {
    final habito = await getHabitoById(habitoId);
    final concluidos = await getTotalConclusoes(habitoId);
    // Adicionado '!' pois a data_inicio é obrigatória
    final decorridos =
        calcularDiasDecorridos(habito.dataInicio!, habito.dataTermino);

    return {
      'habito': habito,
      'concluidos': concluidos,
      'decorridos': decorridos,
    };
  }
}
