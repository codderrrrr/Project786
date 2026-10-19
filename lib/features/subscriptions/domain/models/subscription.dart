import 'package:decimal/decimal.dart';

class Subscription {
  final String id;
  final String subscriberId;
  final String serviceId;
  final String status; // active, cancelled, expired
  final Decimal price;
  final String billingPeriod;
  final String startDate; // YYYY-MM-DD
  final String nextPaymentDate; // YYYY-MM-DD
  final String? endDate; // YYYY-MM-DD
  final bool cancelled;

  Subscription({
    required this.id,
    required this.subscriberId,
    required this.serviceId,
    required this.status,
    required this.price,
    required this.billingPeriod,
    required this.startDate,
    required this.nextPaymentDate,
    this.endDate,
    this.cancelled = false,
  });
}
