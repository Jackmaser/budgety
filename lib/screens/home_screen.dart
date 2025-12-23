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

// Die verschiedenen Filter-Modi
enum FilterType { total, month, quarter, year }

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
  FilterType _currentFilter = FilterType.total;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- FILTER LOGIK ---
  List<Transaction> get _filteredTransactions {
    switch (_currentFilter) {
      case FilterType.month:
        return _transactions
            .where((tx) =>
                tx.date.year == _selectedDate.year &&
                tx.date.month == _selectedDate.month)
            .toList();
      case FilterType.year:
        return _transactions
            .where((tx) => tx.date.year == _selectedDate.year)
            .toList();
      case FilterType.quarter:
        int targetQuarter = (_selectedDate.month - 1) ~/ 3 + 1;
        return _transactions.where((tx) {
          int txQuarter = (tx.date.month - 1) ~/ 3 + 1;
          return tx.date.year == _selectedDate.year &&
              txQuarter == targetQuarter;
        }).toList();
      case FilterType.total:
      default:
        return _transactions;
    }
  }

  String get _detailedFilterLabel {
    switch (_currentFilter) {
      case FilterType.month:
        return DateFormat('MMMM yyyy', 'de_DE').format(_selectedDate);
      case FilterType.quarter:
        int quarter = (_selectedDate.month - 1) ~/ 3 + 1;
        return 'Q$quarter ${_selectedDate.year}';
      case FilterType.year:
        return 'Jahr ${_selectedDate.year}';
      case FilterType.total:
        return 'Gesamtübersicht';
    }
  }

  void _movePeriod(int direction) {
    setState(() {
      switch (_currentFilter) {
        case FilterType.month:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month + direction);
          break;
        case FilterType.quarter:
          _selectedDate = DateTime(
              _selectedDate.year, _selectedDate.month + (direction * 3));
          break;
        case FilterType.year:
          _selectedDate =
              DateTime(_selectedDate.year + direction, _selectedDate.month);
          break;
        case FilterType.total:
          break;
      }
    });
  }

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
        sorted.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
    return sorted;
  }

  // --- SPEICHERN & LADEN ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_categories',
        jsonEncode(_categories.map((c) => c.toMap()).toList()));
    await prefs.setString('user_transactions',
        jsonEncode(_transactions.map((t) => t.toMap()).toList()));
    await prefs.setInt('selected_chart_type', _selectedChartType.index);
    await prefs.setInt('category_sort_pref', _currentSort.index);
    await prefs.setInt('current_filter_pref', _currentFilter.index);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final catsRaw = prefs.getString('user_categories');
    final txsRaw = prefs.getString('user_transactions');
    final chartIndex = prefs.getInt('selected_chart_type');
    final sortIndex = prefs.getInt('category_sort_pref');
    final filterIndex = prefs.getInt('current_filter_pref');

    setState(() {
      if (catsRaw != null) {
        _categories = (jsonDecode(catsRaw) as List)
            .map((i) => Category.fromMap(i))
            .toList();
      } else {
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
      if (txsRaw != null) {
        _transactions = (jsonDecode(txsRaw) as List)
            .map((i) => Transaction.fromMap(i))
            .toList();
      }
      if (chartIndex != null) _selectedChartType = ChartType.values[chartIndex];
      if (sortIndex != null)
        _currentSort = CategorySortOption.values[sortIndex];
      if (filterIndex != null) _currentFilter = FilterType.values[filterIndex];
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

  void _updateTransaction(
      String id, String title, double amount, Category category) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      setState(() {
        _transactions[index] = Transaction(
          id: id,
          title: title,
          amount: amount,
          date: _transactions[index].date,
          category: category,
        );
      });
      _saveData();
    }
  }

  void _deleteTransaction(String id) {
    setState(() => _transactions.removeWhere((tx) => tx.id == id));
    _saveData();
  }

  void _updateCategory(Category updatedCat) {
    final index = _categories.indexWhere((c) => c.id == updatedCat.id);
    if (index >= 0) {
      setState(() {
        _categories[index] = updatedCat;
        for (int i = 0; i < _transactions.length; i++) {
          if (_transactions[i].category.id == updatedCat.id) {
            _transactions[i] = Transaction(
              id: _transactions[i].id,
              title: _transactions[i].title,
              amount: _transactions[i].amount,
              date: _transactions[i].date,
              category: updatedCat,
            );
          }
        }
      });
      _saveData();
    }
  }

  void _resetAllData() {
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
      _selectedChartType = ChartType.pie;
      _currentSort = CategorySortOption.custom;
      _currentFilter = FilterType.total;
      _selectedDate = DateTime.now();
    });
  }

  void _openTransactionForm({Transaction? tx}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => NewTransaction(
        addTx: _addNewTransaction,
        updateTx: _updateTransaction,
        categories: _sortedCategories,
        editingTransaction: tx,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filteredTxs = _filteredTransactions;
    double totalAmount =
        filteredTxs.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgety',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: MainDrawer(
        onShowCategories: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => CategoryScreen(
              categories: _sortedCategories,
              onAddCategory: (c) {
                setState(() => _categories.add(c));
                _saveData();
              },
              onUpdateCategory: _updateCategory,
              onDeleteCategory: (id) {
                setState(() => _categories.removeWhere((c) => c.id == id));
                _saveData();
              },
            ),
          ));
        },
        onShowSettings: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SettingsScreen(
              onDataReset: _resetAllData,
              currentSort: _currentSort,
              onSortChanged: (newSort) {
                setState(() => _currentSort = newSort);
                _saveData();
              },
            ),
          ));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kompakterer Summen-Bereich
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Padding verringert
              child: Card(
                color: isDarkMode
                    ? const Color(0xFF003333)
                    : Theme.of(context).colorScheme.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16), // Padding innen verringert
                      child: Center(
                        child: Text(
                          currencyFormatter.format(totalAmount),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28, // Schriftgröße leicht reduziert
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: PopupMenuButton<FilterType>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white, size: 20),
                        tooltip: 'Zeitraum',
                        onSelected: (FilterType selected) {
                          setState(() {
                            _currentFilter = selected;
                            _selectedDate = DateTime.now();
                          });
                          _saveData();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: FilterType.month, child: Text('Monat')),
                          const PopupMenuItem(
                              value: FilterType.quarter,
                              child: Text('Quartal')),
                          const PopupMenuItem(
                              value: FilterType.year, child: Text('Jahr')),
                          const PopupMenuItem(
                              value: FilterType.total, child: Text('Gesamt')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ChartView(
              transactions: filteredTxs,
              selectedType: _selectedChartType,
              periodTitle: _detailedFilterLabel,
              showArrows: _currentFilter != FilterType.total,
              onPrevious: () => _movePeriod(-1),
              onNext: () => _movePeriod(1),
              onTypeChanged: (newType) {
                setState(() => _selectedChartType = newType);
                _saveData();
              },
            ),

            TransactionList(
              transactions: filteredTxs,
              deleteTx: _deleteTransaction,
              onEditTx: (tx) => _openTransactionForm(tx: tx),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTransactionForm(),
        label: const Text('Neue Buchung'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _addCategory(Category c) {
    setState(() => _categories.add(c));
    _saveData();
  }
}
