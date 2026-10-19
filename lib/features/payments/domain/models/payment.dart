import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';

class Payment {
  final String id;
  final String subscriberId;
  final String subscriberName;
  final List<PaymentItem> items;
  final Decimal calculatedAmount;
  final Decimal billedAmount;
  final Decimal finalAmount;
  final String paymentDate; // YYYY-MM-DD
  final String status; // success
  final String? receiptId;
  final String? notes;

  Payment({
    required this.id,
    required this.subscriberId,
    required this.subscriberName,
    required this.items,
    required this.calculatedAmount,
    required this.billedAmount,
    required this.finalAmount,
    required this.paymentDate,
    required this.status,
    this.receiptId,
    this.notes,
  });
}
