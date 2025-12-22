import 'package:flutter/material.dart';
import '../models/transaction.dart';

class NewTransaction extends StatefulWidget {
  final Function(String, double, TransactionCategory) addTx;

  const NewTransaction(this.addTx, {super.key});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.food;

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return; // Beendet die Funktion, wenn Eingabe ungültig
    }

    widget.addTx(
      enteredTitle,
      enteredAmount,
      _selectedCategory,
    );

    Navigator.of(context)
        .pop(); // Schließt das Bottom Sheet nach dem Hinzufügen
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Titel'),
              controller: _titleController,
              onSubmitted: (_) => _submitData(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Betrag (€)'),
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _submitData(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Kategorie: "),
                DropdownButton<TransactionCategory>(
                  value: _selectedCategory,
                  items: TransactionCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}
