import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class NewTransaction extends StatefulWidget {
  final Function(String, double, Category, DateTime) addTx;
  final Function(String, String, double, Category, DateTime) updateTx;
  final List<Category> categories;
  final Transaction? editingTransaction;

  const NewTransaction({
    super.key,
    required this.addTx,
    required this.updateTx,
    required this.categories,
    this.editingTransaction,
  });

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now(); // Standard: Heute

  @override
  void initState() {
    super.initState();
    if (widget.editingTransaction != null) {
      _titleController.text = widget.editingTransaction!.title;
      _amountController.text =
          widget.editingTransaction!.amount.toString().replaceAll('.', ',');
      _selectedDate = widget.editingTransaction!.date;
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.editingTransaction!.category.id,
        orElse: () => widget.categories.first,
      );
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories[0];
    }
  }

  // Öffnet den Flutter DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // Bis zu 1 Jahr im Voraus
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    final title = _titleController.text;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    if (title.isEmpty || amount <= 0 || _selectedCategory == null) return;

    if (widget.editingTransaction != null) {
      widget.updateTx(widget.editingTransaction!.id, title, amount,
          _selectedCategory!, _selectedDate);
    } else {
      widget.addTx(title, amount, _selectedCategory!, _selectedDate);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.editingTransaction != null
                ? 'Buchung bearbeiten'
                : 'Neue Buchung',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titel'),
            autofocus: true,
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Betrag'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          // DATUMSAUSWAHL ZEILE
          Row(
            children: [
              Expanded(
                child: Text(
                  'Datum: ${DateFormat('dd.MM.yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: _presentDatePicker,
                child: const Text('Datum wählen',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButton<Category>(
            value: _selectedCategory,
            isExpanded: true,
            items: widget.categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(cat.icon, color: cat.color),
                    const SizedBox(width: 10),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _submitData,
                child: Text(widget.editingTransaction != null
                    ? 'Speichern'
                    : 'Hinzufügen')),
          ),
        ],
      ),
    );
  }
}
