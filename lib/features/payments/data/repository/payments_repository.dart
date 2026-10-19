import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';

abstract class PaymentsRepository {
  Future<CursorPage<Payment>> listPayments({String? cursor, int limit = 20, String? subscriberId});
  Future<Payment?> getPayment(String id);
  Future<Payment> createPayment({
    required String subscriberId,
    required List<PaymentItem> items,
    required Decimal calculatedAmount,
    required Decimal billedAmount,
    required String idempotencyKey,
    String? notes,
  });
}
