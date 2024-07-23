import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/firebase_options.dart';
import 'package:scorebuddy/services/auth/auth_gate.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          background: Colors.black,
          primary: Colors.amber,
          secondary: Colors.deepPurple,
          tertiary: Colors.blueGrey 
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

