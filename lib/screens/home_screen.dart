import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_list.dart';
import '../widgets/new_transaction.dart';
import '../widgets/main_drawer.dart';
import '../widgets/chart_view.dart'; // Neu importieren
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

  // State für den Diagramm-Typ
  ChartType _selectedChartType = ChartType.pie;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- SPEICHERN & LADEN (Erweitert um ChartType) ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_categories',
        jsonEncode(_categories.map((c) => c.toMap()).toList()));
    await prefs.setString('user_transactions',
        jsonEncode(_transactions.map((t) => t.toMap()).toList()));
    await prefs.setInt('selected_chart_type', _selectedChartType.index);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesRaw = prefs.getString('user_categories');
    final transactionsRaw = prefs.getString('user_transactions');
    final chartIndex = prefs.getInt('selected_chart_type');

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
      if (chartIndex != null) {
        _selectedChartType = ChartType.values[chartIndex];
      }
    });
  }

  // --- LOGIK ---
  void _addNewTransaction(String title, double amount, Category category) {
    setState(() {
      _transactions.add(Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
      ));
    });
    _saveData();
  }

  void _deleteTransaction(String id) {
    setState(() => _transactions.removeWhere((tx) => tx.id == id));
    _saveData();
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
        onShowCategories: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => CategoryScreen(
            categories: _categories,
            onAddCategory: (c) {
              setState(() => _categories.add(c));
              _saveData();
            },
            onDeleteCategory: (id) {
              setState(() => _categories.removeWhere((c) => c.id == id));
              _saveData();
            },
          ),
        )),
      ),
      body: Column(
        children: [
          // Grüne Karte für Gesamtausgaben
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

          // DIAGRAMM-ANSICHT (Wird unter der grünen Karte eingefügt)
          ChartView(
            transactions: _transactions,
            selectedType: _selectedChartType,
            onTypeChanged: (newType) {
              setState(() => _selectedChartType = newType);
              _saveData();
            },
          ),

          // Liste der Transaktionen
          Expanded(
            child: TransactionList(
              transactions: _transactions,
              deleteTx: _deleteTransaction,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => NewTransaction(
                addTx: _addNewTransaction, categories: _categories),
          );
        },
        label: const Text('Neue Buchung'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
