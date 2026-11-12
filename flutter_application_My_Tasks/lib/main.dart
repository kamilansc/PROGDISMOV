import 'package:flutter/material.dart';
import 'package:flutter_application_my_tasks/controller_tarefa.dart';
import 'package:flutter_application_my_tasks/gerenciador_banco.dart';
import 'package:flutter_application_my_tasks/model_tarefa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Tasks'),
          centerTitle: true,
          toolbarHeight: 40,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home', icon: Icon(Icons.home_rounded)),
              Tab(text: 'To do', icon: Icon(Icons.task_alt_rounded)),
            ],
          ),
        ),
        body: TabBarView(children: [HomeScreen(), TodoListPage()]),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Home'),
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //   ),
    //   body: ListView(
    //   padding: const EdgeInsets.all(8),
    //   children: [
    //     ListTile(
    //       leading: const Icon(Icons.task_alt_rounded),
    //       title: const Text('To do'),
    //       onTap: () => Navigator.pushNamed(context, '/toDoList'),
    //     ),
    //   ],
    // ),
    // );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ControllerTarefa _controller = ControllerTarefa(GerenciadorBanco());
  late Future<Map<String, int>> _quantidadeTarefas;

  @override
  void initState() {
    super.initState();
    _quantidadeTarefas = _controller.contarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Olá, Kamila!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Organize suas atividades do dia e acompanhe seu progresso.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            FutureBuilder<Map<String, int>>(
              future: _quantidadeTarefas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Erro ao carregar métricas');
                }

                final metricas = snapshot.data!;

                return Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: 28,
                                color: Colors.indigo,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                '${metricas['totalTarefas']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),

                              const SizedBox(height: 8),

                              Text('Total de tarefas'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        color: const Color.fromARGB(255, 255, 249, 226),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pending_actions_rounded,
                                size: 28,
                                color: Colors.indigo,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                '${metricas['tarefasPendentes']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),

                              const SizedBox(height: 8),

                              Text('Pendentes'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            Text(
              'Como usar o My Tasks?',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_circle_rounded,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          title: const Text(
                            'Adicione tarefas na aba To do',
                            style: TextStyle(fontSize: 13),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),

                        const Divider(height: 0.5, indent: 16, endIndent: 16),

                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          title: const Text(
                            'Marque as tarefas quando concluí-las',
                            style: TextStyle(fontSize: 13),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),

                        const Divider(height: 0.5, indent: 16, endIndent: 16),

                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bar_chart_rounded,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          title: const Text(
                            'Veja o total de tarefas e quantas ainda faltam.',
                            style: TextStyle(fontSize: 13),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final ControllerTarefa _controller = ControllerTarefa(GerenciadorBanco());
  final TextEditingController _campoTarefa = TextEditingController();
  late Future<List<Tarefa>> _tarefasFuture;

  @override
  void initState() {
    super.initState();
    _tarefasFuture = _controller.buscarTarefas();
  }

  @override
  void dispose() {
    _campoTarefa.dispose();
    super.dispose();
  }

  void _recarregarTarefas() {
    setState(() {
      _tarefasFuture = _controller.buscarTarefas();
    });
  }

  Future<void> _adicionarTarefa() async {
    final nome = _campoTarefa.text;
    if (nome.trim().isEmpty) return;

    await _controller.adicionarTarefa(nome);
    _campoTarefa.clear();
    _recarregarTarefas();
  }

  Future<void> _alterarConclusao(Tarefa tarefa, bool concluida) async {
    await _controller.atualizarConclusao(tarefa, concluida);
    _recarregarTarefas();
  }

  Future<void> _excluirTarefa(Tarefa tarefa) async {
    await _controller.excluirTarefa(tarefa.id!);
    _recarregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _campoTarefa,
              decoration: const InputDecoration(
                hintText: 'Anote uma tarefa para lembrar',
              ),
              onSubmitted: (_) => _adicionarTarefa(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar tarefas: ${snapshot.error}'),
                  );
                }

                final tarefas = snapshot.data ?? [];
                if (tarefas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa cadastrada.'),
                  );
                }

                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
                    return ListTile(
                      title: Text(tarefa.nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (valor) => _excluirTarefa(tarefa),
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'excluir',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Excluir tarefa'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Checkbox(
                            value: tarefa.concluida,
                            shape: const CircleBorder(),
                            onChanged: (valor) =>
                                _alterarConclusao(tarefa, valor ?? false),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTarefa,
        tooltip: 'Adicionar item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
