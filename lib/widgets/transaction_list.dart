import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? const Center(child: Text('Noch keine Buchungen vorhanden!'))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final tx = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text(
                          '${tx.amount.toStringAsFixed(2)}€',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  title: Text(tx.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(tx.date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Lösch-Logik folgt
                    },
                  ),
                ),
              );
            },
          );
  }
}
