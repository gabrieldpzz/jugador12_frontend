import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Si ya generaste firebase_options.dart con FlutterFire CLI, descomenta estas dos líneas
// import 'firebase_options.dart';

import 'pages/home_page.dart'; // o tu primera pantalla

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opción A (simple, te funciona en Android si ya pusiste google-services.json):
  await Firebase.initializeApp();

  // Opción B (si usas FlutterFire CLI y tienes firebase_options.dart):
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jugador12',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
