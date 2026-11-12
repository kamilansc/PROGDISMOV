import 'package:flutter_application_my_tasks/gerenciador_banco.dart';
import 'package:flutter_application_my_tasks/model_tarefa.dart';

/// Faz a ligação entre a tela e as operações do banco de dados.
class ControllerTarefa {
  final GerenciadorBanco _banco;

  ControllerTarefa(this._banco);

  Future<List<Tarefa>> buscarTarefas() {
    return _banco.buscarTarefas();
  }

  Future<Map<String, int>> contarTarefas() async {
    final List<Tarefa> tarefas = await _banco.buscarTarefas();
    final int pendentes = tarefas.where((tarefa) => !(tarefa.concluida)).length;

    return {'totalTarefas': tarefas.length, 'tarefasPendentes': pendentes};
  }

  Future<void> adicionarTarefa(String nome) async {
    final nomeLimpo = nome.trim();
    if (nomeLimpo.isEmpty) return;

    await _banco.inserirTarefa(Tarefa(nome: nomeLimpo, concluida: false));
  }

  Future<void> atualizarConclusao(Tarefa tarefa, bool concluida) async {
    await _banco.atualizarTarefa(
      Tarefa(id: tarefa.id, nome: tarefa.nome, concluida: concluida),
    );
  }

  Future<void> excluirTarefa(int idTarefa) async {
    await _banco.excluirTarefa(idTarefa);
  }
}
