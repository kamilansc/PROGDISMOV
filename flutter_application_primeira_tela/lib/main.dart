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
      debugShowCheckedModeBanner: false,
      title: 'Meu App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(
        title: 'Minha primeira tela Flutter',
        userName: 'Kamila',
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.userName});
  final String title;
  final String userName;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Text('Drawer Header'),
            ),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('Saldo')),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Extratos'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Pagamentos'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/pexels-image-background.jpg',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.25),
            ),
          ),
          _selectedIndex == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Olá, ${widget.userName}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            const Text(
                              'Quantidade de vezes que você pressionou o botão:',
                            ),
                            Text(
                              '$_counter',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: const <Widget>[
                    ListTile(
                      leading: CircleAvatar(child: Text('A')),
                      title: Text('Headline'),
                      subtitle: Text('Supporting text'),
                      trailing: Icon(Icons.favorite_rounded),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: CircleAvatar(child: Text('B')),
                      title: Text('Headline'),
                      subtitle: Text(
                        'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.',
                      ),
                      trailing: Icon(Icons.favorite_rounded),
                    ),
                  ],
                ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
              ],
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        ],
      ),
    );
  }
}
