import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_list.dart';
import '../widgets/new_transaction.dart';
import '../widgets/main_drawer.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Die Liste der Buchungen
  final List<Transaction> _transactions = [];

  // Die Liste der verfügbaren Kategorien (wird an andere Widgets übergeben)
  final List<Category> _categories = [
    Category(
        id: 'c1', name: 'Essen', icon: Icons.restaurant, color: Colors.orange),
    Category(
        id: 'c2',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue),
    Category(
        id: 'c3', name: 'Freizeit', icon: Icons.movie, color: Colors.green),
  ];

  // Berechnet die Gesamtsumme aller Buchungen
  double get _totalAmount {
    return _transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Logik: Neue Transaktion zur Liste hinzufügen
  void _addNewTransaction(String title, double amount, Category category) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );

    setState(() {
      _transactions.add(newTx);
    });
  }

  // Logik: Transaktion löschen
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  // Logik: Neue Kategorie hinzufügen (wird im CategoryScreen aufgerufen)
  void _addCategory(Category cat) {
    setState(() {
      _categories.add(cat);
    });
  }

  // Logik: Kategorie löschen (wird im CategoryScreen aufgerufen)
  void _deleteCategory(String id) {
    setState(() {
      // Hinweis: In einer echten App müssten wir hier prüfen, ob noch Transaktionen
      // an dieser Kategorie hängen, bevor wir sie löschen.
      _categories.removeWhere((cat) => cat.id == id);
    });
  }

  // Öffnet das Modal-Fenster für neue Buchungen
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return NewTransaction(
          addTx: _addNewTransaction,
          categories: _categories,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatter für die Anzeige der Gesamtsumme (Deutsch: Komma statt Punkt)
    final currencyFormatter =
        NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgety',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      // Das Seitenmenü
      drawer: MainDrawer(
        onShowCategories: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => CategoryScreen(
                categories: _categories,
                onAddCategory: _addCategory,
                onDeleteCategory: _deleteCategory,
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // Header-Bereich mit Kontostand
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                child: Column(
                  children: [
                    const Text(
                      'Gesamtausgaben',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(_totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Liste der Buchungen
          Expanded(
            child: TransactionList(
              transactions: _transactions,
              deleteTx: _deleteTransaction,
            ),
          ),
        ],
      ),
      // Button zum Hinzufügen einer neuen Buchung
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startAddNewTransaction(context),
        label: const Text('Neue Buchung'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
