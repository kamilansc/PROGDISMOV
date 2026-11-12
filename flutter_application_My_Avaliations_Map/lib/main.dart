import 'package:flutter/material.dart';

import 'views/mapa_view.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const MapaView(title: 'Maps Sample App'),
    );
  }
}
