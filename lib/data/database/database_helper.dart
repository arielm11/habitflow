import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Nome do arquivo do BD
  static const _databaseName = 'habitflow.db';
  // Versão do BD
  static const _databaseVersion = 2;

  // Nome da tabela de Hábitos
  static const tableHabitos = 'habitos';

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
      // onUpgrade: _onUpgrade,
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
  }

  // Adicionando coluna
  // Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   await db.execute('''
  //     ALTER TABLE $tableHabitos
  //     ADD COLUMN descricao TEXT;
  //   ''');
  // }

  // Métodos CRUD

  // C - Create:  Inserir um novo hábito no banco de dados
  Future<int> insertHabit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableHabitos, row);
  }

  // R - Read: Ler todos os habitos
  Future<List<Map<String, dynamic>>> queryAllHabits() async {
    Database db = await instance.database;
    return await db.query(tableHabitos, orderBy: "id DESC");
  }
}
