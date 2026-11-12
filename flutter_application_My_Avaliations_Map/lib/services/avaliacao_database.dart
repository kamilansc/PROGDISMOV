import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/avaliacao.dart';

class AvaliacaoDatabase {
  AvaliacaoDatabase._();

  static final AvaliacaoDatabase instance = AvaliacaoDatabase._();
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    try {
      return await (_databaseFuture ??= _abrirDatabase());
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _abrirDatabase() async {
    final caminho = join(await getDatabasesPath(), 'avaliacoes.db');
    return openDatabase(
      caminho,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE avaliacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            apelido TEXT NOT NULL,
            comentario TEXT NOT NULL,
            nota INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> inserir(Avaliacao avaliacao) async {
    final db = await database;
    return db.insert('avaliacoes', avaliacao.toMap());
  }

  Future<List<Avaliacao>> listar() async {
    final db = await database;
    final linhas = await db.query('avaliacoes', orderBy: 'id ASC');
    return linhas.map(Avaliacao.fromMap).toList();
  }
}
