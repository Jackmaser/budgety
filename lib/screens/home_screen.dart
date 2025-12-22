import 'dart:convert'; // Für jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Transaction> _transactions = [];
  List<Category> _categories = [
    Category(
        id: 'c1', name: 'Essen', icon: Icons.restaurant, color: Colors.orange),
    Category(
        id: 'c2',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _loadData(); // Daten beim Start laden
  }

  // --- SPEICHER-LOGIK ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Kategorien speichern
    final categoriesJson =
        jsonEncode(_categories.map((c) => c.toMap()).toList());
    await prefs.setString('user_categories', categoriesJson);

    // Transaktionen speichern
    final transactionsJson =
        jsonEncode(_transactions.map((t) => t.toMap()).toList());
    await prefs.setString('user_transactions', transactionsJson);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final categoriesRaw = prefs.getString('user_categories');
    final transactionsRaw = prefs.getString('user_transactions');

    setState(() {
      if (categoriesRaw != null) {
        final List<dynamic> decoded = jsonDecode(categoriesRaw);
        _categories = decoded.map((item) => Category.fromMap(item)).toList();
      }
      if (transactionsRaw != null) {
        final List<dynamic> decoded = jsonDecode(transactionsRaw);
        _transactions =
            decoded.map((item) => Transaction.fromMap(item)).toList();
      }
    });
  }

  // --- UI LOGIK ---

  void _addNewTransaction(String title, double amount, Category category) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );
    setState(() => _transactions.add(newTx));
    _saveData(); // Speichern nach Hinzufügen
  }

  void _deleteTransaction(String id) {
    setState(() => _transactions.removeWhere((tx) => tx.id == id));
    _saveData(); // Speichern nach Löschen
  }

  void _addCategory(Category cat) {
    setState(() => _categories.add(cat));
    _saveData(); // Speichern nach Hinzufügen
  }

  void _deleteCategory(String id) {
    setState(() => _categories.removeWhere((cat) => cat.id == id));
    _saveData(); // Speichern nach Löschen
  }

  // (Rest wie vorher...)
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) =>
          NewTransaction(addTx: _addNewTransaction, categories: _categories),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'de_DE', symbol: '€');
    double totalAmount =
        _transactions.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgety'), centerTitle: true),
      drawer: MainDrawer(
        onShowCategories: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => CategoryScreen(
              categories: _categories,
              onAddCategory: _addCategory,
              onDeleteCategory: _deleteCategory,
            ),
          ));
        },
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Gesamtausgaben',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      currencyFormatter.format(totalAmount),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: TransactionList(
                  transactions: _transactions, deleteTx: _deleteTransaction)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startAddNewTransaction(context),
        label: const Text('Neue Buchung'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
