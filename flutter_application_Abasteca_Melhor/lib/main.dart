import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: 'Abasteça Melhor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double resultado = 0;
  String mensagem = '';
  Icon iconePadrao = Icon(Icons.announcement_rounded, color: Colors.blueGrey);
  Icon icone = Icon(Icons.announcement_rounded, color: Colors.blueGrey);

  final TextEditingController _textEditeControllerGasolina =
      TextEditingController();
  final TextEditingController _textEditeControllerAlcool =
      TextEditingController();

  void determinarParecer() {
    final gasolina = double.tryParse(_textEditeControllerGasolina.text);
    final alcool = double.tryParse(_textEditeControllerAlcool.text);

    if (gasolina == null || alcool == null || gasolina == 0) {
      setState(() {
        mensagem = 'Digite valores numéricos válidos!';
        icone = const Icon(Icons.error_rounded, color: Colors.deepOrange);
      });
      return;
    }
    setState(() {
      resultado = alcool / gasolina * 100;

      if (resultado <= 70) {
        mensagem = 'Abastecer com álcool';
        icone = const Icon(
          Icons.local_gas_station_rounded,
          color: Colors.green,
        );
      } else {
        mensagem = 'Abastecer com gasolina';
        icone = const Icon(
          Icons.local_gas_station_rounded,
          color: Colors.orange,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: Text('Gasolina VS Álcool'),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: Text(
                'Esse app tem o intuito de calcular e lhe informar qual combustível está mais econômico com base nos valores informados por você. Experimente!',
                textAlign: TextAlign.justify,
              ),
            ),

            Column(
              mainAxisAlignment: .center,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  child: Image.network(
                    'https://www.c-store.com.au/wp-content/uploads/2018/09/iStock-504743184.jpg?w=1024',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 5,
                    horizontal: 50,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Valor do álcool'),
                    ),
                    controller: _textEditeControllerAlcool,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 5,
                    horizontal: 50,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Valor da gasolina'),
                    ),
                    controller: _textEditeControllerGasolina,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 25,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _textEditeControllerAlcool.clear();
                        _textEditeControllerGasolina.clear();
                        setState(() {
                          mensagem = '';
                        });
                      },
                      child: const Text('Limpar'),
                    ),

                    // const SizedBox(width: 25),
                    ElevatedButton(
                      onPressed: () {
                        determinarParecer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                      ),
                      child: const Text('Calcular'),
                    ),
                  ],
                ),

                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      mensagem.isEmpty ? iconePadrao : icone,
                      Text(
                        mensagem.isEmpty
                            ? 'Digite os valores nos campos acima'
                            : mensagem,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
