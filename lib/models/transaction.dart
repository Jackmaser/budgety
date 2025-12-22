import 'category.dart'; // Importieren

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category; // Jetzt die Klasse statt Enum

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
