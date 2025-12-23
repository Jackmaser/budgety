import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_list.dart';
import '../widgets/new_transaction.dart';
import '../widgets/main_drawer.dart';
import '../widgets/chart_view.dart';
import 'category_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  ChartType _selectedChartType = ChartType.pie;
  CategorySortOption _currentSort = CategorySortOption.custom;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Sortierte Kategorien zurückgeben
  List<Category> get _sortedCategories {
    List<Category> sorted = List.from(_categories);
    switch (_currentSort) {
      case CategorySortOption.alphabetical:
        sorted.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case CategorySortOption.lastModified:
        sorted.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case CategorySortOption.custom:
        // Keine Sortierung = Erstellungsreihenfolge (da IDs Zeitstempel sind)
        sorted.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
    return sorted;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_categories',
        jsonEncode(_categories.map((c) => c.toMap()).toList()));
    await prefs.setString('user_transactions',
        jsonEncode(_transactions.map((t) => t.toMap()).toList()));
    await prefs.setInt('selected_chart_type', _selectedChartType.index);
    await prefs.setInt('category_sort_pref', _currentSort.index);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final catsRaw = prefs.getString('user_categories');
    final txsRaw = prefs.getString('user_transactions');
    final sortIndex = prefs.getInt('category_sort_pref');

    setState(() {
      if (catsRaw != null) {
        _categories = (jsonDecode(catsRaw) as List)
            .map((i) => Category.fromMap(i))
            .toList();
      } else {
        // Fallback falls leer
        _categories = [
          Category(
              id: 'c1',
              name: 'Essen',
              icon: Icons.restaurant,
              color: Colors.orange,
              lastModified: DateTime.now()),
          Category(
              id: 'c2',
              name: 'Transport',
              icon: Icons.directions_car,
              color: Colors.blue,
              lastModified: DateTime.now()),
        ];
      }
      if (txsRaw != null)
        _transactions = (jsonDecode(txsRaw) as List)
            .map((i) => Transaction.fromMap(i))
            .toList();
      if (sortIndex != null)
        _currentSort = CategorySortOption.values[sortIndex];
    });
  }

  void _addCategory(Category c) {
    setState(() => _categories.add(c));
    _saveData();
  }

  void _updateCategory(Category updatedCat) {
    final index = _categories.indexWhere((c) => c.id == updatedCat.id);
    if (index >= 0) {
      // Neuen Zeitstempel setzen
      final catWithNewTimestamp = Category(
        id: updatedCat.id,
        name: updatedCat.name,
        icon: updatedCat.icon,
        color: updatedCat.color,
        lastModified: DateTime.now(),
      );
      setState(() {
        _categories[index] = catWithNewTimestamp;
        // Transaktionen synchronisieren...
        for (int i = 0; i < _transactions.length; i++) {
          if (_transactions[i].category.id == updatedCat.id) {
            _transactions[i] = Transaction(
              id: _transactions[i].id,
              title: _transactions[i].title,
              amount: _transactions[i].amount,
              date: _transactions[i].date,
              category: catWithNewTimestamp,
            );
          }
        }
      });
      _saveData();
    }
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
            categories: _sortedCategories, // Hier die sortierte Liste übergeben
            onAddCategory: _addCategory,
            onUpdateCategory: _updateCategory,
            onDeleteCategory: (id) {
              setState(() => _categories.removeWhere((c) => c.id == id));
              _saveData();
            },
          ),
        )),
        onShowSettings: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => SettingsScreen(
            currentSort: _currentSort,
            onSortChanged: (newSort) {
              setState(() => _currentSort = newSort);
              _saveData();
            },
            onDataReset: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              setState(() {
                _transactions = [];
                _categories = [
                  Category(
                      id: 'c1',
                      name: 'Essen',
                      icon: Icons.restaurant,
                      color: Colors.orange,
                      lastModified: DateTime.now()),
                ];
              });
              if (mounted) Navigator.of(context).pop();
            },
          ),
        )),
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
                child: Column(children: [
                  const Text('Gesamtausgaben',
                      style: TextStyle(color: Colors.white70)),
                  Text(currencyFormatter.format(totalAmount),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ),
          ChartView(
              transactions: _transactions,
              selectedType: _selectedChartType,
              onTypeChanged: (t) {
                setState(() => _selectedChartType = t);
                _saveData();
              }),
          Expanded(
            child: TransactionList(
                transactions: _transactions,
                deleteTx: (id) {
                  setState(() => _transactions.removeWhere((t) => t.id == id));
                  _saveData();
                },
                onEditTx: (tx) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => NewTransaction(
                      addTx: (t, a, c) {
                        setState(() => _transactions.add(Transaction(
                            id: DateTime.now().toString(),
                            title: t,
                            amount: a,
                            date: DateTime.now(),
                            category: c)));
                        _saveData();
                      },
                      updateTx: (id, t, a, c) {
                        final i = _transactions.indexWhere((tx) => tx.id == id);
                        setState(() => _transactions[i] = Transaction(
                            id: id,
                            title: t,
                            amount: a,
                            date: _transactions[i].date,
                            category: c));
                        _saveData();
                      },
                      categories: _sortedCategories,
                      editingTransaction: tx,
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => NewTransaction(
                addTx: (t, a, c) {
                  setState(() => _transactions.add(Transaction(
                      id: DateTime.now().toString(),
                      title: t,
                      amount: a,
                      date: DateTime.now(),
                      category: c)));
                  _saveData();
                },
                updateTx: (id, t, a, c) {},
                categories: _sortedCategories,
              ),
            );
          },
          label: const Text('Neue Buchung'),
          icon: const Icon(Icons.add)),
    );
  }
}
