import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) deleteTx;
  final Function(Transaction) onEditTx;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.deleteTx,
    required this.onEditTx,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return transactions.isEmpty
        ? const Center(child: Text('Keine Buchungen.'))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, i) {
              final tx = transactions[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.category.color.withOpacity(0.2),
                    child: Icon(tx.category.icon, color: tx.category.color),
                  ),
                  title: Text(tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(tx.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currencyFormatter.format(tx.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => onEditTx(tx),
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTx(tx.id)),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
