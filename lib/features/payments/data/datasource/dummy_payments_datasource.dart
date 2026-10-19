import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor_utils.dart';
import 'package:subscription_saas_flutter/features/payments/data/datasource/dummy_payments_store.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/datasource/dummy_subscribers_store.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';

class DummyPaymentsDatasource {
  Future<CursorPage<Payment>> listPayments({String? cursor, int limit = 20, String? subscriberId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = DummyPaymentsStore.all();
    var filtered = all;
    if (subscriberId != null && subscriberId.isNotEmpty) {
      filtered = all.where((e) => e.subscriberId == subscriberId).toList();
    }
    final offset = CursorUtils.decode(cursor);
    final end = (offset + limit) > filtered.length ? filtered.length : (offset + limit);
    final items = offset >= filtered.length ? <Payment>[] : filtered.sublist(offset, end);
    final next = end < filtered.length ? CursorUtils.encode(end) : null;
    return CursorPage(items: items, nextCursor: next, hasMore: next != null);
  }

  Future<Payment?> getPayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return DummyPaymentsStore.all().firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Payment> createPayment({
    required String subscriberId,
    required List<PaymentItem> items,
    required Decimal calculatedAmount,
    required Decimal billedAmount,
    required String idempotencyKey,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final subs = DummySubscribersStore.all();
    final subName = subs.firstWhere((x) => x.id == subscriberId, orElse: () => subs.first).name;
    final today = BizDate.todayYMD();
    final payment = Payment(
      id: 'pay_${DateTime.now().microsecondsSinceEpoch}',
      subscriberId: subscriberId,
      subscriberName: subName,
      items: items,
      calculatedAmount: calculatedAmount,
      billedAmount: billedAmount,
      finalAmount: billedAmount,
      paymentDate: today,
      status: 'success',
      receiptId: 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
      notes: notes,
    );
    DummyPaymentsStore.add(payment);
    return payment;
  }
}
