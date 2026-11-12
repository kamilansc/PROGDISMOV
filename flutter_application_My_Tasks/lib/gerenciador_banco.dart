import 'package:flutter_application_my_tasks/model_tarefa.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Centraliza a abertura do SQLite e as consultas da tabela de tarefas.
class GerenciadorBanco {
  Database? _db;

  Future<Database> _verificarBanco() async {
    if (_db != null && _db!.isOpen) return _db!;

    final pasta = await getDatabasesPath();
    // Mantém o mesmo arquivo usado pela versão inicial do aplicativo.
    final caminho = join(pasta, 'tasks.db');
    _db = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            concluida INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await _verificarBanco();
    return db.insert('tarefas', tarefa.toMap());
  }

  Future<List<Tarefa>> buscarTarefas() async {
    final db = await _verificarBanco();
    final resultado = await db.query('tarefas', orderBy: 'id DESC');
    return resultado.map(Tarefa.fromMap).toList();
  }

  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await _verificarBanco();
    return db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<void> excluirTarefa(int idTarefa) async {
    final db = await _verificarBanco();

    await db.delete('tarefas', where: 'id = ?', whereArgs: [idTarefa]);
  }
}
