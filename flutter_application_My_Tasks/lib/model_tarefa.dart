class Tarefa {
  int? id;
  String nome;
  bool concluida;

  Tarefa({required this.nome, required this.concluida, this.id});

  static Tarefa fromMap(Map<String, Object?> input) {
    return Tarefa(
      id: input['id'] as int?,
      nome: input['nome'].toString(),
      concluida: input['concluida'] == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {'nome': nome, 'concluida': concluida ? 1 : 0};
  }
}
