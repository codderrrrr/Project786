import 'package:decimal/decimal.dart';

class PaymentItem {
  final String subscriptionId;
  final String serviceName;
  final Decimal amount;
  final String dueDate;

  PaymentItem({
    required this.subscriptionId,
    required this.serviceName,
    required this.amount,
    required this.dueDate,
  });
}
