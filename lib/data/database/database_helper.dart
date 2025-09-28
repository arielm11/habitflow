import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Nome do arquivo do BD
  static const _databaseName = 'habitflow.db';
  // Versão do BD
  static const _databaseVersion = 1;

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
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  //
}
