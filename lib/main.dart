import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BudgetyApp());
}

class BudgetyApp extends StatelessWidget {
  const BudgetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
