import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

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

    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text('Keine Buchungen vorhanden.')),
      );
    }

    // 1. Gesamtwert aller Ausgaben berechnen für die Prozentanzeige
    final totalSum = transactions.fold(0.0, (sum, item) => sum + item.amount);

    // 2. Transaktionen nach Kategorien gruppieren
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in transactions) {
      if (!groupedTransactions.containsKey(tx.category.id)) {
        groupedTransactions[tx.category.id] = [];
      }
      groupedTransactions[tx.category.id]!.add(tx);
    }

    // 3. Die Liste der Kategorien IDs (für den Builder)
    final categoryIds = groupedTransactions.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryIds.length,
      itemBuilder: (ctx, index) {
        final catId = categoryIds[index];
        final txsInCat = groupedTransactions[catId]!;

        // Chronologisch sortieren (Neueste zuerst innerhalb der Kategorie)
        txsInCat.sort((a, b) => b.date.compareTo(a.date));

        final catTotal = txsInCat.fold(0.0, (sum, item) => sum + item.amount);
        final percentage = (catTotal / totalSum) * 100;
        final category = txsInCat.first.category;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            shape: const Border(), // Entfernt die Trennlinien beim Ausklappen
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${currencyFormatter.format(catTotal)} • ${percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            children: txsInCat.map((tx) {
              return Column(
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    title: Text(tx.title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      DateFormat('dd.MM.yyyy').format(tx.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencyFormatter.format(tx.amount),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.blue),
                          onPressed: () => onEditTx(tx),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          onPressed: () => deleteTx(tx.id),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
