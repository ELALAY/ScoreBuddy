import 'package:flutter/material.dart';
import 'package:scorebuddy/Screens/home.dart';

void main() {
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
      home: const MyHomePage(),
    );
  }
}

