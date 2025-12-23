import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class NewTransaction extends StatefulWidget {
  final Function(String, double, Category) addTx;
  final Function(String, String, double, Category) updateTx;
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

  @override
  void initState() {
    super.initState();
    if (widget.editingTransaction != null) {
      // Vorausfüllen im Bearbeitungsmodus
      _titleController.text = widget.editingTransaction!.title;
      _amountController.text =
          widget.editingTransaction!.amount.toString().replaceAll('.', ',');
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.editingTransaction!.category.id,
        orElse: () => widget.categories.first,
      );
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories[0];
    }
  }

  void _submitData() {
    final title = _titleController.text;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    if (title.isEmpty || amount <= 0 || _selectedCategory == null) return;

    if (widget.editingTransaction != null) {
      widget.updateTx(
          widget.editingTransaction!.id, title, amount, _selectedCategory!);
    } else {
      widget.addTx(title, amount, _selectedCategory!);
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
              decoration: const InputDecoration(labelText: 'Titel')),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Betrag'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
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
          ElevatedButton(
              onPressed: _submitData,
              child: Text(widget.editingTransaction != null
                  ? 'Speichern'
                  : 'Hinzufügen')),
        ],
      ),
    );
  }
}
