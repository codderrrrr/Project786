import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/payments/data/datasource/dummy_payments_datasource.dart';
import 'package:subscription_saas_flutter/features/payments/data/repository/payments_repository.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final DummyPaymentsDatasource datasource;
  PaymentsRepositoryImpl(this.datasource);

  @override
  Future<CursorPage<Payment>> listPayments({
    String? cursor,
    int limit = 20,
    String? subscriberId,
  }) {
    return datasource.listPayments(
      cursor: cursor,
      limit: limit,
      subscriberId: subscriberId,
    );
  }

  @override
  Future<Payment?> getPayment(String id) {
    return datasource.getPayment(id);
  }

  @override
  Future<Payment> createPayment({
    required String subscriberId,
    required List<PaymentItem> items,
    required Decimal calculatedAmount,
    required Decimal billedAmount,
    required String idempotencyKey,
    String? notes,
  }) {
    return datasource.createPayment(
      subscriberId: subscriberId,
      items: items,
      calculatedAmount: calculatedAmount,
      billedAmount: billedAmount,
      idempotencyKey: idempotencyKey,
      notes: notes,
    );
  }
}
