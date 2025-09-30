import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Nome do arquivo do BD
  static const _databaseName = 'habitflow.db';
  // Versão do BD
  static const _databaseVersion = 3;

  // Nome da tabela de Hábitos
  static const tableHabitos = 'habitos';
  // Nome da tabela de Registro de Processos
  static const tableRegistros = 'registros_progresso';

  // Instânciando esse único objeto
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializando o BD
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Criando Tabela
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHabitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        tipoMeta TEXT NOT NULL,
        metaValor TEXT,
        ativo INTEGER NOT NULL
      )
    ''');

    await db.execute('''
          CREATE TABLE $tableRegistros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitoId INTEGER NOT NULL,
            data TEXT NOT NULL,
            FOREIGN KEY (habitoId) REFERENCES $tableHabitos (id)
          )
          ''');
  }

  // Adicionando coluna
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE $tableHabitos
      ADD COLUMN descricao TEXT;
    ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
          CREATE TABLE $tableRegistros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitoId INTEGER NOT NULL,
            data TEXT NOT NULL,
            FOREIGN KEY (habitoId) REFERENCES $tableHabitos (id)
          )
          ''');
    }
  }

  // Métodos CRUD para hábitos

  // C - Create: Inserir um novo hábito no banco de dados
  Future<int> insertHabit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableHabitos, row);
  }

  // R - Read: Ler todos os habitos
  Future<List<Map<String, dynamic>>> queryAllHabits() async {
    Database db = await instance.database;
    return await db.query(tableHabitos, orderBy: "id DESC");
  }

  // U - Update: Atualiza um hábito existente
  Future<int> updateHabit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];

    return await db.update(tableHabitos, row, where: 'id = ?', whereArgs: [id]);
  }

  // D - Delete: Deletar um hábito
  Future<int> deleteHabit(int id) async {
    Database db = await instance.database;

    return await db.delete(tableHabitos, where: 'id = ?', whereArgs: [id]);
  }

  // Métodos CRUD para registro de progresso
  // C - Create: Insere um registro de progresso
  Future<void> insertRegistro(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(tableRegistros, row);
  }

  // R - Read: Busca todos os registros de uma data específica
  Future<List<Map<String, dynamic>>> queryRegistrosPorData(String data) async {
    Database db = await instance.database;
    return await db.query(
      tableRegistros,
      where: 'data = ?',
      whereArgs: [data],
    );
  }

  // D - Delete: Deleta um registro de progresso para um hábito em uma data específica
  Future<void> deleteRegistro(int habitoId, String data) async {
    Database db = await instance.database;
    await db.delete(
      tableRegistros,
      where: 'habitoId = ? AND data = ?',
      whereArgs: [habitoId, data],
    );
  }
}
