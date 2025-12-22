enum TransactionCategory { food, transport, leisure, work, health, other }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
