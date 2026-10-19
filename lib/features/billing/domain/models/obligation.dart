import 'package:decimal/decimal.dart';

class Obligation {
  final String id;
  final String subscriberId;
  final String subscriberName;
  final List<String> subscriptionIds;
  final List<String> serviceNames;
  final Decimal amountDue; // calculated/total
  final String dueDate; // YYYY-MM-DD
  final String status; // due, overdue
  final int daysOverdue;
  final int daysDue;

  Obligation({
    required this.id,
    required this.subscriberId,
    required this.subscriberName,
    required this.subscriptionIds,
    required this.serviceNames,
    required this.amountDue,
    required this.dueDate,
    required this.status,
    required this.daysOverdue,
    required this.daysDue,
  });
}
