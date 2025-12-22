import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Beispiel-Daten
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Lebensmittel',
      amount: 45.50,
      date: DateTime.now(),
      category: TransactionCategory.food,
    ),
    Transaction(
      id: 't2',
      title: 'Tanken',
      amount: 80.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: TransactionCategory.transport,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgety'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          const SizedBox(
              height: 20,
              child: Center(child: Text("Hier kommt später ein Chart hin"))),
          Expanded(
            child: TransactionList(transactions: _transactions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logik zum Hinzufügen folgt im nächsten Schritt
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
